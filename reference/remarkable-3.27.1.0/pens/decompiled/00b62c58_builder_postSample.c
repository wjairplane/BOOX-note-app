
undefined8 FUN_00b62c58(int param_1)

{
  int iVar1;
  float fVar2;
  float fVar3;
  uint uVar4;
  int iVar5;
  uint in_fpscr;
  float fVar6;
  float fVar7;
  double local_50;
  double local_48;
  double local_40;
  double local_38;
  double local_30;
  double local_28;
  double local_20;
  double local_18;
  
  if (*(int *)(param_1 + 0x54) < 2) {
    local_30 = 0.0;
  }
  else {
    iVar1 = FUN_00b5f574(param_1 + 0x40);
    iVar1 = (iVar1 + -1) * 0xe;
    iVar5 = *(int *)(param_1 + 0x50) + iVar1;
    fVar2 = *(float *)(*(int *)(param_1 + 0x50) + iVar1);
    fVar3 = *(float *)(iVar5 + 4);
    uVar4 = *(uint *)(iVar5 + 8);
    iVar1 = FUN_00b5f574(param_1 + 0x40);
    iVar1 = (iVar1 + -2) * 0xe;
    iVar5 = *(int *)(param_1 + 0x50) + iVar1;
    fVar6 = (float)VectorUnsignedToFloat(uVar4 >> 0x10,(byte)(in_fpscr >> 0x15) & 3);
    fVar7 = (float)VectorUnsignedToFloat(*(uint *)(iVar5 + 8) >> 0x10,(byte)(in_fpscr >> 0x15) & 3);
    local_40 = (double)(fVar6 * 0.25 * 0.5);
    local_20 = (double)(fVar7 * 0.25 * 0.5);
    local_48 = (double)fVar3 - local_40;
    local_50 = (double)fVar2 - local_40;
    local_28 = (double)*(float *)(iVar5 + 4) - local_20;
    local_30 = (double)*(float *)(*(int *)(param_1 + 0x50) + iVar1) - local_20;
    local_40 = local_40 + 0.0 + local_40;
    local_20 = local_20 + 0.0 + local_20;
    local_38 = local_40;
    local_18 = local_20;
    local_30 = (double)QRectF::operator|((QRectF *)&local_50,(QRectF *)&local_30);
  }
  return local_30;
}

