#
# This class is automatically generated by mig. DO NOT EDIT THIS FILE.
# This class implements a Python interface to the 'ReadToastVersionResponseMsg'
# message type.
#

import tinyos.message.Message

# The default size of this message type in bytes.
DEFAULT_MESSAGE_SIZE = 4

# The Active Message type associated with this message.
AM_TYPE = 173

class ReadToastVersionResponseMsg(tinyos.message.Message.Message):
    # Create a new ReadToastVersionResponseMsg of size 4.
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
        s = "Message <ReadToastVersionResponseMsg> \n"
        try:
            s += "  [error=0x%x]\n" % (self.get_error())
        except:
            pass
        try:
            s += "  [tag=0x%x]\n" % (self.get_tag())
        except:
            pass
        try:
            s += "  [version=0x%x]\n" % (self.get_version())
        except:
            pass
        return s

    # Message-type-specific access methods appear below.

    #
    # Accessor methods for field: error
    #   Field type: short
    #   Offset (bits): 0
    #   Size (bits): 8
    #

    #
    # Return whether the field 'error' is signed (False).
    #
    def isSigned_error(self):
        return False
    
    #
    # Return whether the field 'error' is an array (False).
    #
    def isArray_error(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'error'
    #
    def offset_error(self):
        return (0 / 8)
    
    #
    # Return the offset (in bits) of the field 'error'
    #
    def offsetBits_error(self):
        return 0
    
    #
    # Return the value (as a short) of the field 'error'
    #
    def get_error(self):
        return self.getUIntElement(self.offsetBits_error(), 8, 1)
    
    #
    # Set the value of the field 'error'
    #
    def set_error(self, value):
        self.setUIntElement(self.offsetBits_error(), 8, value, 1)
    
    #
    # Return the size, in bytes, of the field 'error'
    #
    def size_error(self):
        return (8 / 8)
    
    #
    # Return the size, in bits, of the field 'error'
    #
    def sizeBits_error(self):
        return 8
    
    #
    # Accessor methods for field: tag
    #   Field type: short
    #   Offset (bits): 8
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
        return (8 / 8)
    
    #
    # Return the offset (in bits) of the field 'tag'
    #
    def offsetBits_tag(self):
        return 8
    
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
    # Accessor methods for field: version
    #   Field type: int
    #   Offset (bits): 16
    #   Size (bits): 16
    #

    #
    # Return whether the field 'version' is signed (False).
    #
    def isSigned_version(self):
        return False
    
    #
    # Return whether the field 'version' is an array (False).
    #
    def isArray_version(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'version'
    #
    def offset_version(self):
        return (16 / 8)
    
    #
    # Return the offset (in bits) of the field 'version'
    #
    def offsetBits_version(self):
        return 16
    
    #
    # Return the value (as a int) of the field 'version'
    #
    def get_version(self):
        return self.getUIntElement(self.offsetBits_version(), 16, 1)
    
    #
    # Set the value of the field 'version'
    #
    def set_version(self, value):
        self.setUIntElement(self.offsetBits_version(), 16, value, 1)
    
    #
    # Return the size, in bytes, of the field 'version'
    #
    def size_version(self):
        return (16 / 8)
    
    #
    # Return the size, in bits, of the field 'version'
    #
    def sizeBits_version(self):
        return 16
    
