
int FUN_00b6ea90(float param_1,float param_2)

{
  uint uVar1;
  uint uVar2;
  uint uVar3;
  uint in_fpscr;
  float fVar4;
  float fVar5;
  uint uVar6;
  uint uVar7;
  int iVar8;
  int iVar9;
  
  uVar6 = (uint)param_1;
  uVar1 = in_fpscr & 0xfffffff | (uint)(param_2 < 0.0) << 0x1f;
  uVar7 = (uint)param_2;
  if (param_1 < 0.0) {
    uVar2 = uVar6 - 1;
  }
  else {
    uVar2 = uVar6;
    uVar6 = uVar6 + 1;
  }
  if (SUB41(uVar1 >> 0x1f,0)) {
    uVar3 = uVar7;
    uVar7 = uVar7 - 1;
  }
  else {
    uVar3 = uVar7 + 1;
  }
  fVar4 = (float)VectorSignedToFloat(uVar2,(byte)(uVar1 >> 0x15) & 3);
  fVar5 = (float)VectorSignedToFloat(uVar7,(byte)(uVar1 >> 0x15) & 3);
  iVar8 = (int)((param_1 - fVar4) * DAT_00b6eb70);
  iVar9 = (int)((param_2 - fVar5) * DAT_00b6eb70);
  return (int)((0xff - iVar9) *
               ((0xff - iVar8) *
                (uint)(byte)(&DAT_011dd648)
                            [(uint)(byte)(&DAT_011dd648)[uVar7 & 0xff] + (uVar2 & 0xff)] +
               iVar8 * (uint)(byte)(&DAT_011dd610)
                                   [(uint)(byte)(&DAT_011dd648)[uVar7 & 0xff] + (uVar6 & 0xff) +
                                    0x38]) +
              iVar9 * ((0xff - iVar8) *
                       (uint)(byte)(&DAT_011dd648)
                                   [(uint)(byte)(&DAT_011dd648)[uVar3 & 0xff] + (uVar2 & 0xff)] +
                      iVar8 * (uint)(byte)(&DAT_011dd610)
                                          [(uint)(byte)(&DAT_011dd648)[uVar3 & 0xff] +
                                           (uVar6 & 0xff) + 0x38])) >> 0x10;
}

