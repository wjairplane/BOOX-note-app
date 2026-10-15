
void FUN_00b6c850(int *param_1,undefined8 *param_2)

{
  undefined4 uVar1;
  undefined4 uVar2;
  int iVar3;
  undefined8 uVar4;
  undefined4 local_40;
  undefined4 uStack_3c;
  undefined4 uStack_38;
  undefined8 local_30;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 local_20;
  
  FUN_00b6ae4c();
  uVar4 = *param_2;
  local_28 = *(undefined4 *)(param_2 + 1);
  iVar3 = *param_1;
  if (*(int *)((int)param_2 + 0x14) == 0) {
    local_24 = 0x3f800000;
  }
  else {
    local_24 = VectorFloatToUnsignedFixed((uint)*(ushort *)(*(int *)(param_2 + 2) + 10),0x20,2);
  }
  local_20 = 1;
  local_30._0_4_ = (undefined4)uVar4;
  local_30._4_4_ = (undefined4)((ulonglong)uVar4 >> 0x20);
  uVar1 = local_30._4_4_;
  uVar2 = (undefined4)local_30;
  local_30 = uVar4;
  FUN_00b70b10(&local_40,iVar3,uVar2,uVar1,local_28,local_24,1);
  *(undefined4 *)(iVar3 + 0x1c) = local_40;
  *(undefined4 *)(iVar3 + 0x20) = uStack_3c;
  *(undefined4 *)(iVar3 + 0x24) = uStack_38;
  FUN_00b6bed4(param_1,param_2);
  return;
}

