
void FUN_00b74cd8(int param_1)

{
  undefined8 uVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  
  if (*(char *)(param_1 + 0x4e) == '\x02') {
    if ((*(float *)(param_1 + 0x3c) == *(float *)(param_1 + 0x74)) &&
       (*(float *)(param_1 + 0x40) == *(float *)(param_1 + 0x78))) {
      FUN_00b74960(*(float *)(param_1 + 0x74));
      FUN_00b65ee4(*(undefined4 *)(param_1 + 0x5c),*(undefined4 *)(param_1 + 0x60),
                   *(undefined4 *)(param_1 + 0x6c),*(undefined4 *)(param_1 + 0x70),
                   *(undefined4 *)(param_1 + 0x8c),*(undefined4 *)(param_1 + 0x90),
                   *(undefined4 *)(param_1 + 0x9c),*(undefined4 *)(param_1 + 0xa0),param_1);
    }
    else {
      if (*(char *)(param_1 + 0xac) == '\0') {
        FUN_00b65c30(*(undefined4 *)(param_1 + 0x8c),*(undefined4 *)(param_1 + 0x90),
                     *(undefined4 *)(param_1 + 0x94),*(undefined4 *)(param_1 + 0x98),
                     *(undefined4 *)(param_1 + 0x9c),*(undefined4 *)(param_1 + 0xa0),
                     *(undefined4 *)(param_1 + 0xa4),*(undefined4 *)(param_1 + 0xa8),param_1);
        *(undefined1 *)(param_1 + 0xac) = 1;
        if ((*(char *)(param_1 + 0xad) != '\0') || (*(char *)(param_1 + 0x4e) != '\x02'))
        goto LAB_00b74cec;
      }
      else if (*(char *)(param_1 + 0xad) != '\0') goto LAB_00b74cec;
      FUN_00b65c30(*(undefined4 *)(param_1 + 0x54),*(undefined4 *)(param_1 + 0x58),
                   *(undefined4 *)(param_1 + 0x5c),*(undefined4 *)(param_1 + 0x60),
                   *(undefined4 *)(param_1 + 100),*(undefined4 *)(param_1 + 0x68),
                   *(undefined4 *)(param_1 + 0x6c),*(undefined4 *)(param_1 + 0x70),param_1,1);
    }
  }
LAB_00b74cec:
  uVar4 = DAT_00b74e68;
  uVar3 = DAT_00b74e60;
  uVar2 = DAT_00b74e58;
  uVar1 = DAT_00b74e50;
  *(undefined8 *)(param_1 + 0x8c) = 0;
  *(undefined8 *)(param_1 + 0x94) = 0;
  *(undefined8 *)(param_1 + 0x9c) = 0;
  *(undefined8 *)(param_1 + 0xa4) = 0;
  *(undefined4 *)(param_1 + 0x48) = 0;
  *(undefined2 *)(param_1 + 0x4e) = 0;
  *(undefined1 *)(param_1 + 0x50) = 0;
  *(undefined8 *)(param_1 + 0x74) = uVar1;
  *(undefined8 *)(param_1 + 0x7c) = uVar2;
  *(undefined2 *)(param_1 + 0x86) = 0;
  *(undefined1 *)(param_1 + 0x88) = 0;
  *(undefined4 *)(param_1 + 0x34) = 0;
  *(undefined8 *)(param_1 + 0x38) = uVar3;
  *(undefined8 *)(param_1 + 0x40) = uVar4;
  *(undefined2 *)(param_1 + 0xac) = 0;
  return;
}

