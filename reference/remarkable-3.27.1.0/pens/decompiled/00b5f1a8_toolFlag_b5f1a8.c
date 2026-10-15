
uint FUN_00b5f1a8(uint param_1)

{
  uint uVar1;
  
  if (param_1 < 0x18) {
    uVar1 = 0x81900bU >> (param_1 & 0xff) & 1;
  }
  else {
    uVar1 = 0;
  }
  return uVar1;
}

