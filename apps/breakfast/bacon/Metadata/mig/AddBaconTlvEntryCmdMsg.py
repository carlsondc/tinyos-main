#
# This class is automatically generated by mig. DO NOT EDIT THIS FILE.
# This class implements a Python interface to the 'AddBaconTlvEntryCmdMsg'
# message type.
#

import tinyos.message.Message

# The default size of this message type in bytes.
DEFAULT_MESSAGE_SIZE = 130

# The Active Message type associated with this message.
AM_TYPE = 164

class AddBaconTlvEntryCmdMsg(tinyos.message.Message.Message):
    # Create a new AddBaconTlvEntryCmdMsg of size 130.
    def __init__(self, data="", addr=None, gid=None, base_offset=0, data_length=130):
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
        s = "Message <AddBaconTlvEntryCmdMsg> \n"
        try:
            s += "  [tag=0x%x]\n" % (self.get_tag())
        except:
            pass
        try:
            s += "  [len=0x%x]\n" % (self.get_len())
        except:
            pass
        try:
            s += "  [data=";
            for i in range(0, 128):
                s += "0x%x " % (self.getElement_data(i) & 0xff)
            s += "]\n";
        except:
            pass
        return s

    # Message-type-specific access methods appear below.

    #
    # Accessor methods for field: tag
    #   Field type: short
    #   Offset (bits): 0
    #   Size (bits): 8
    #

    #
    # Return whether the field 'tag' is signed (False).
    #
    def isSigned_tag(self):
        return False
    
    #
    # Return whether the field 'tag' is an array (False).
    #
    def isArray_tag(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'tag'
    #
    def offset_tag(self):
        return (0 / 8)
    
    #
    # Return the offset (in bits) of the field 'tag'
    #
    def offsetBits_tag(self):
        return 0
    
    #
    # Return the value (as a short) of the field 'tag'
    #
    def get_tag(self):
        return self.getUIntElement(self.offsetBits_tag(), 8, 1)
    
    #
    # Set the value of the field 'tag'
    #
    def set_tag(self, value):
        self.setUIntElement(self.offsetBits_tag(), 8, value, 1)
    
    #
    # Return the size, in bytes, of the field 'tag'
    #
    def size_tag(self):
        return (8 / 8)
    
    #
    # Return the size, in bits, of the field 'tag'
    #
    def sizeBits_tag(self):
        return 8
    
    #
    # Accessor methods for field: len
    #   Field type: short
    #   Offset (bits): 8
    #   Size (bits): 8
    #

    #
    # Return whether the field 'len' is signed (False).
    #
    def isSigned_len(self):
        return False
    
    #
    # Return whether the field 'len' is an array (False).
    #
    def isArray_len(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'len'
    #
    def offset_len(self):
        return (8 / 8)
    
    #
    # Return the offset (in bits) of the field 'len'
    #
    def offsetBits_len(self):
        return 8
    
    #
    # Return the value (as a short) of the field 'len'
    #
    def get_len(self):
        return self.getUIntElement(self.offsetBits_len(), 8, 1)
    
    #
    # Set the value of the field 'len'
    #
    def set_len(self, value):
        self.setUIntElement(self.offsetBits_len(), 8, value, 1)
    
    #
    # Return the size, in bytes, of the field 'len'
    #
    def size_len(self):
        return (8 / 8)
    
    #
    # Return the size, in bits, of the field 'len'
    #
    def sizeBits_len(self):
        return 8
    
    #
    # Accessor methods for field: data
    #   Field type: short[]
    #   Offset (bits): 16
    #   Size of each element (bits): 8
    #

    #
    # Return whether the field 'data' is signed (False).
    #
    def isSigned_data(self):
        return False
    
    #
    # Return whether the field 'data' is an array (True).
    #
    def isArray_data(self):
        return True
    
    #
    # Return the offset (in bytes) of the field 'data'
    #
    def offset_data(self, index1):
        offset = 16
        if index1 < 0 or index1 >= 128:
            raise IndexError
        offset += 0 + index1 * 8
        return (offset / 8)
    
    #
    # Return the offset (in bits) of the field 'data'
    #
    def offsetBits_data(self, index1):
        offset = 16
        if index1 < 0 or index1 >= 128:
            raise IndexError
        offset += 0 + index1 * 8
        return offset
    
    #
    # Return the entire array 'data' as a short[]
    #
    def get_data(self):
        tmp = [None]*128
        for index0 in range (0, self.numElements_data(0)):
                tmp[index0] = self.getElement_data(index0)
        return tmp
    
    #
    # Set the contents of the array 'data' from the given short[]
    #
    def set_data(self, value):
        for index0 in range(0, len(value)):
            self.setElement_data(index0, value[index0])

    #
    # Return an element (as a short) of the array 'data'
    #
    def getElement_data(self, index1):
        return self.getUIntElement(self.offsetBits_data(index1), 8, 1)
    
    #
    # Set an element of the array 'data'
    #
    def setElement_data(self, index1, value):
        self.setUIntElement(self.offsetBits_data(index1), 8, value, 1)
    
    #
    # Return the total size, in bytes, of the array 'data'
    #
    def totalSize_data(self):
        return (1024 / 8)
    
    #
    # Return the total size, in bits, of the array 'data'
    #
    def totalSizeBits_data(self):
        return 1024
    
    #
    # Return the size, in bytes, of each element of the array 'data'
    #
    def elementSize_data(self):
        return (8 / 8)
    
    #
    # Return the size, in bits, of each element of the array 'data'
    #
    def elementSizeBits_data(self):
        return 8
    
    #
    # Return the number of dimensions in the array 'data'
    #
    def numDimensions_data(self):
        return 1
    
    #
    # Return the number of elements in the array 'data'
    #
    def numElements_data():
        return 128
    
    #
    # Return the number of elements in the array 'data'
    # for the given dimension.
    #
    def numElements_data(self, dimension):
        array_dims = [ 128,  ]
        if dimension < 0 or dimension >= 1:
            raise IndexException
        if array_dims[dimension] == 0:
            raise IndexError
        return array_dims[dimension]
    
    #
    # Fill in the array 'data' with a String
    #
    def setString_data(self, s):
         l = len(s)
         for i in range(0, l):
             self.setElement_data(i, ord(s[i]));
         self.setElement_data(l, 0) #null terminate
    
    #
    # Read the array 'data' as a String
    #
    def getString_data(self):
        carr = "";
        for i in range(0, 4000):
            if self.getElement_data(i) == chr(0):
                break
            carr += self.getElement_data(i)
        return carr
    
