
void FUN_00b74f20(undefined4 param_1,undefined4 param_2,undefined4 param_3,int param_4,
                 undefined4 param_5,undefined4 param_6,undefined4 param_7)

{
  int iVar1;
  undefined4 uStack00000004;
  undefined4 uStack00000008;
  undefined4 uStack0000000c;
  
  *(undefined4 *)(*(int *)(param_4 + 4) + 4) = param_3;
  uStack00000004 = param_5;
  uStack00000008 = param_6;
  uStack0000000c = param_7;
  FUN_00b74960();
  iVar1 = *(int *)(param_4 + 4);
  if ((*(char *)(iVar1 + 0xac) == '\0') && (*(char *)(iVar1 + 0x4e) == '\x02')) {
    FUN_00b65c30(*(undefined4 *)(iVar1 + 0x8c),*(undefined4 *)(iVar1 + 0x90),
                 *(undefined4 *)(iVar1 + 0x94),*(undefined4 *)(iVar1 + 0x98),
                 *(undefined4 *)(iVar1 + 0x9c),*(undefined4 *)(iVar1 + 0xa0),
                 *(undefined4 *)(iVar1 + 0xa4),*(undefined4 *)(iVar1 + 0xa8),iVar1);
    *(undefined1 *)(iVar1 + 0xac) = 1;
    return;
  }
  return;
}

