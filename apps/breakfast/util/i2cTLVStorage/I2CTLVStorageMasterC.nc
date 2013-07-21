#include "I2CTLVStorage.h"
//wrap storage commands with I2C behavior
//to preserve storage interface, use Set to determine slave addr
configuration I2CTLVStorageMasterC{
  provides interface I2CTLVStorageMaster;
  provides interface TLVUtils;
} implementation {
  components I2CTLVStorageMasterP;
  components new TLVUtilsC(SLAVE_TLV_LEN);
  
  components new I2CComMasterClientC(I2C_COM_CLIENT_ID_TLV_STORAGE);

  I2CTLVStorageMasterP.I2CComMaster -> I2CComMasterClientC;
  I2CTLVStorageMasterP.TLVUtils -> TLVUtilsC;

  I2CTLVStorageMaster = I2CTLVStorageMasterP;

  TLVUtils = TLVUtilsC;
}
