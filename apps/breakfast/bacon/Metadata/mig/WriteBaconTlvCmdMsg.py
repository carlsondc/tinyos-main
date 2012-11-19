#
# This class is automatically generated by mig. DO NOT EDIT THIS FILE.
# This class implements a Python interface to the 'WriteBaconTlvCmdMsg'
# message type.
#

import tinyos.message.Message

# The default size of this message type in bytes.
DEFAULT_MESSAGE_SIZE = 64

# The Active Message type associated with this message.
AM_TYPE = 156

class WriteBaconTlvCmdMsg(tinyos.message.Message.Message):
    # Create a new WriteBaconTlvCmdMsg of size 64.
    def __init__(self, data="", addr=None, gid=None, base_offset=0, data_length=64):
        tinyos.message.Message.Message.__init__(self, data, addr, gid, base_offset, data_length)
        self.amTypeSet(AM_TYPE)
    
    # Get AM_TYPE
    def get_amType(cls):
        return AM_TYPE
    
    get_amType = classmethod(get_amType)
    
    #
    # Return a String representation of this message. Includes the
    # message type name and the non-indexed field values.
    #
    def __str__(self):
        s = "Message <WriteBaconTlvCmdMsg> \n"
        try:
            s += "  [tlvs=";
            for i in range(0, 64):
                s += "0x%x " % (self.getElement_tlvs(i) & 0xff)
            s += "]\n";
        except:
            pass
        return s

    # Message-type-specific access methods appear below.

    #
    # Accessor methods for field: tlvs
    #   Field type: short[]
    #   Offset (bits): 0
    #   Size of each element (bits): 8
    #

    #
    # Return whether the field 'tlvs' is signed (False).
    #
    def isSigned_tlvs(self):
        return False
    
    #
    # Return whether the field 'tlvs' is an array (True).
    #
    def isArray_tlvs(self):
        return True
    
    #
    # Return the offset (in bytes) of the field 'tlvs'
    #
    def offset_tlvs(self, index1):
        offset = 0
        if index1 < 0 or index1 >= 64:
            raise IndexError
        offset += 0 + index1 * 8
        return (offset / 8)
    
    #
    # Return the offset (in bits) of the field 'tlvs'
    #
    def offsetBits_tlvs(self, index1):
        offset = 0
        if index1 < 0 or index1 >= 64:
            raise IndexError
        offset += 0 + index1 * 8
        return offset
    
    #
    # Return the entire array 'tlvs' as a short[]
    #
    def get_tlvs(self):
        tmp = [None]*64
        for index0 in range (0, self.numElements_tlvs(0)):
                tmp[index0] = self.getElement_tlvs(index0)
        return tmp
    
    #
    # Set the contents of the array 'tlvs' from the given short[]
    #
    def set_tlvs(self, value):
        for index0 in range(0, len(value)):
            self.setElement_tlvs(index0, value[index0])

    #
    # Return an element (as a short) of the array 'tlvs'
    #
    def getElement_tlvs(self, index1):
        return self.getUIntElement(self.offsetBits_tlvs(index1), 8, 1)
    
    #
    # Set an element of the array 'tlvs'
    #
    def setElement_tlvs(self, index1, value):
        self.setUIntElement(self.offsetBits_tlvs(index1), 8, value, 1)
    
    #
    # Return the total size, in bytes, of the array 'tlvs'
    #
    def totalSize_tlvs(self):
        return (512 / 8)
    
    #
    # Return the total size, in bits, of the array 'tlvs'
    #
    def totalSizeBits_tlvs(self):
        return 512
    
    #
    # Return the size, in bytes, of each element of the array 'tlvs'
    #
    def elementSize_tlvs(self):
        return (8 / 8)
    
    #
    # Return the size, in bits, of each element of the array 'tlvs'
    #
    def elementSizeBits_tlvs(self):
        return 8
    
    #
    # Return the number of dimensions in the array 'tlvs'
    #
    def numDimensions_tlvs(self):
        return 1
    
    #
    # Return the number of elements in the array 'tlvs'
    #
    def numElements_tlvs():
        return 64
    
    #
    # Return the number of elements in the array 'tlvs'
    # for the given dimension.
    #
    def numElements_tlvs(self, dimension):
        array_dims = [ 64,  ]
        if dimension < 0 or dimension >= 1:
            raise IndexException
        if array_dims[dimension] == 0:
            raise IndexError
        return array_dims[dimension]
    
    #
    # Fill in the array 'tlvs' with a String
    #
    def setString_tlvs(self, s):
         l = len(s)
         for i in range(0, l):
             self.setElement_tlvs(i, ord(s[i]));
         self.setElement_tlvs(l, 0) #null terminate
    
    #
    # Read the array 'tlvs' as a String
    #
    def getString_tlvs(self):
        carr = "";
        for i in range(0, 4000):
            if self.getElement_tlvs(i) == chr(0):
                break
            carr += self.getElement_tlvs(i)
        return carr
    
