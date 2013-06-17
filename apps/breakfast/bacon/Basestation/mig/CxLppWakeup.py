#
# This class is automatically generated by mig. DO NOT EDIT THIS FILE.
# This class implements a Python interface to the 'CxLppWakeup'
# message type.
#

import tinyos.message.Message

# The default size of this message type in bytes.
DEFAULT_MESSAGE_SIZE = 4

# The Active Message type associated with this message.
AM_TYPE = 198

class CxLppWakeup(tinyos.message.Message.Message):
    # Create a new CxLppWakeup of size 4.
    def __init__(self, data="", addr=None, gid=None, base_offset=0, data_length=4):
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
        s = "Message <CxLppWakeup> \n"
        try:
            s += "  [timeout=0x%x]\n" % (self.get_timeout())
        except:
            pass
        return s

    # Message-type-specific access methods appear below.

    #
    # Accessor methods for field: timeout
    #   Field type: long
    #   Offset (bits): 0
    #   Size (bits): 32
    #

    #
    # Return whether the field 'timeout' is signed (False).
    #
    def isSigned_timeout(self):
        return False
    
    #
    # Return whether the field 'timeout' is an array (False).
    #
    def isArray_timeout(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'timeout'
    #
    def offset_timeout(self):
        return (0 / 8)
    
    #
    # Return the offset (in bits) of the field 'timeout'
    #
    def offsetBits_timeout(self):
        return 0
    
    #
    # Return the value (as a long) of the field 'timeout'
    #
    def get_timeout(self):
        return self.getUIntElement(self.offsetBits_timeout(), 32, 1)
    
    #
    # Set the value of the field 'timeout'
    #
    def set_timeout(self, value):
        self.setUIntElement(self.offsetBits_timeout(), 32, value, 1)
    
    #
    # Return the size, in bytes, of the field 'timeout'
    #
    def size_timeout(self):
        return (32 / 8)
    
    #
    # Return the size, in bits, of the field 'timeout'
    #
    def sizeBits_timeout(self):
        return 32
    
