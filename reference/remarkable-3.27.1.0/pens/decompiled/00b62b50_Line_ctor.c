
undefined4 * FUN_00b62b50(undefined4 *param_1,undefined4 param_2,int param_3,undefined4 param_4)

{
  undefined8 uVar1;
  undefined8 in_d0;
  
  uVar1 = DAT_00b62c50;
  *(undefined1 *)(param_1 + 0xe) = 0;
  *(undefined8 *)(param_1 + 4) = 0;
  *(undefined8 *)(param_1 + 6) = 0;
  *(undefined8 *)(param_1 + 8) = 0;
  *(undefined8 *)(param_1 + 10) = 0;
  *(undefined8 *)(param_1 + 0xc) = 0;
  *(undefined8 *)(param_1 + 0x10) = uVar1;
  *param_1 = param_2;
  *(undefined8 *)(param_1 + 2) = in_d0;
  param_1[0x12] = 0xff000000;
  *(undefined8 *)(param_1 + 0x13) = 0;
  param_1[0x15] = 0;
  *(undefined1 *)(param_1 + 0x22) = 0;
  *(undefined8 *)(param_1 + 0x16) = 0x3ff0000000000000;
  param_1[0x18] = 0;
  param_1[0x1a] = 0;
  param_1[0x1b] = 0;
  param_1[0x1c] = 0;
  param_1[0x1d] = 0;
  param_1[0x1e] = 0;
  param_1[0x1f] = 0;
  param_1[0x20] = 0;
  param_1[0x21] = 0;
  FUN_00b5f554(param_1 + 0x10);
  param_1[0x11] = param_3;
  FUN_00b5f57c(param_1 + 0x10);
  if (param_3 == 9) {
    param_1[0x12] = param_4;
  }
  return param_1;
}

