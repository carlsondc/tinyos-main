#!/usr/bin/env python
import sqlite3
import sys

def fit(xy):
    '''Work out the best fit line for an array of (x, y)
    tuples and return (isValid, intercept, slope, r-squared)'''

    if not xy:
        return (False, None, None, None)

    if len(xy) == 1:
        print "single point fit for", xy, "assume skewless binary ms"
        (x, y) = xy[0]
        return (True, y-(x*1.0/1024.0), 1.0/1024, 0)
    else:
        xy_bar = sum( 1.0*x*y for (x,y) in xy)/len(xy)
        x_bar  = sum( 1.0*x for (x,y) in xy)/len(xy)
        y_bar  = sum( 1.0*y for (x,y) in xy)/len(xy)
        x2_bar = sum( x**2.0 for (x,y) in xy)/len(xy)
        
        if (x2_bar - x_bar**2) !=0:
            beta = (xy_bar - (x_bar * y_bar))/ (x2_bar - x_bar**2)
            alpha = y_bar - (beta * x_bar)
        
            ss_tot = sum( (y-y_bar )**2.0 for (x,y) in xy)
            F = [ alpha + beta*x for (x,y) in xy]
            ss_res = sum( (y-f )**2.0 for ((x,y), f) in zip(xy, F))
            r_sq = 1- (ss_res/ss_tot)
            return (True, alpha, beta, r_sq)
        else:
            return (False, None, None, None)


#work out best fit for each (node_id, rc) tuple in base_reference
#for each (node_id, rc) tuple in base reference
#  get all (unixTS, nodeTS) tuples
#  compute fit for these tuples
#  stick it into fits table as (node1, rc1, node2, rc2, alpha, beta, r_sq)
# alpha = intercept, beta = slope

def computeFits(dbName):
    c = sqlite3.connect(dbName)
    q0 = '''SELECT distinct node1, rc1 FROM base_reference'''
    q1 = '''SELECT distinct ts1, unixTS FROM base_reference WHERE node1= ? AND rc1 = ?'''
    q2 = '''INSERT INTO fits (node1, rc1, node2, rc2, alpha, beta, r_sq) VALUES (?, ?, NULL, NULL, ?, ?, ?)'''
    for (node, rc) in c.execute(q0).fetchall():
        xy = c.execute(q1, (node, rc)).fetchall()
        (valid, alpha, beta, r_sq) = fit(xy)
        if valid:
            c.execute(q2, (node, rc, alpha, beta, r_sq))
    c.commit()
    c.close()
    #TODO: compute relative fits

    #TODO: for each absolute fit A (in order by r_sq)
    #TODO:   for every segment with relative fit (R) to A that does not have
    #            an absolute fit
    #TODO:     compute an absolute fit on the basis of A and R for
    #            this segment. r_sq for this fit should be... sum?
    #            (this is the distance metric that jay spent so much
    #            time thinking about)

def approxFits(dbName):
    c = sqlite3.connect(dbName)

    q0 = '''SELECT x.node_id as node_id, min(x.reboot_counter) as reboot_counter
      FROM 
      (
        SELECT distinct node_id, reboot_counter FROM
        (
          SELECT node_id, reboot_counter FROM bacon_sample
          UNION
          SELECT node_id, reboot_counter FROM toast_sample
        )
      ) x 
      LEFT JOIN fits ON x.node_id = fits.node1 AND x.reboot_counter=fits.rc1
      LEFT JOIN unmatched ON unmatched.node_id = x.node_id AND unmatched.reboot_counter = x.reboot_counter
      WHERE fits.node1 IS NULL
      AND unmatched.node_id IS NULL
      GROUP BY x.node_id'''

    q1 = '''SELECT fits.node1, fits.rc1, fits.alpha+fits.beta*max(base_time), fits.beta
      FROM fits 
      JOIN (
      SELECT fits.node1 as node1, max(rc1) as rc
      FROM fits
      WHERE fits.node1=?
        AND rc1 < ?
      ) maxRC ON fits.node1=maxRC.node1 and fits.rc1 = maxRC.rc
      JOIN (
        SELECT node_id, reboot_counter, base_time 
        FROM bacon_sample
        UNION
        SELECT node_id, reboot_counter, base_time 
        FROM toast_sample
      ) sampleTimes ON sampleTimes.node_id=maxRC.node1
      AND sampleTimes.reboot_counter = maxRC.rc'''

    q2 = '''INSERT INTO fits 
      (node1, rc1, node2, rc2, alpha, beta, r_sq) 
      VALUES (?, ?, NULL, NULL, ?, ?, ?)'''

    q3 = '''CREATE TEMPORARY TABLE UNMATCHED (
      node_id INTEGER, 
      reboot_counter INTEGER)'''

    q4 = '''INSERT INTO unmatched 
      (node_id, reboot_counter)
      VALUES (?, ?)'''

    c.execute(q3)
    needFits = c.execute(q0).fetchall()
    while needFits:
        for (node_id, reboot_counter) in needFits:
            lastFit = c.execute(q1, (node_id, reboot_counter)).fetchone()
            if lastFit and not lastFit[0] is None:
                (node1, rc1, fakeAlpha, lastBeta) = lastFit
                print "Approximate fit for (%u, %u) "%(node_id, reboot_counter)
                c.execute(q2, (node_id, reboot_counter, fakeAlpha, lastBeta, -1))
            else:
                print "No approximate fit for %u %u"%(node_id, reboot_counter)
                c.execute(q4, (node_id, reboot_counter))
        needFits = c.execute(q0).fetchall()
    c.commit()


def rebuildTables(dbName):
    c = sqlite3.connect(dbName)
    q0 = '''DROP TABLE IF EXISTS fits'''
    q1 = '''CREATE TABLE FITS (node1 INTEGER, rc1 INTEGER, node2 INTEGER, rc2 INTEGER, alpha REAL, beta REAL, r_sq REAL)'''
    c.execute(q0)
    c.execute(q1)
    c.commit()
    c.close()

def phoenix(dbName):
    rebuildTables(dbName)
    computeFits(dbName)
    approxFits(dbName)

if __name__ == '__main__':
    dbName = sys.argv[1]
    phoenix(dbName)
