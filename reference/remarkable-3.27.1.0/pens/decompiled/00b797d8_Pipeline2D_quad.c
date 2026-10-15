
void FUN_00b797d8(float param_1,float param_2,float param_3,float param_4,float param_5,
                 float param_6,float param_7,float param_8,int param_9,int param_10)

{
  uint uVar1;
  uint uVar2;
  byte bVar3;
  int iVar4;
  undefined4 *puVar5;
  undefined4 *puVar6;
  int iVar7;
  uint in_fpscr;
  undefined4 in_s8;
  undefined4 in_s9;
  undefined4 in_s10;
  undefined4 in_s11;
  undefined4 in_s12;
  float fVar8;
  undefined4 in_s13;
  float fVar9;
  undefined4 in_s14;
  float fVar10;
  undefined4 in_s15;
  float fVar11;
  undefined4 uVar12;
  undefined4 uVar13;
  float fVar14;
  float fVar15;
  
  fVar14 = param_7;
  fVar15 = param_6;
  uVar12 = in_s10;
  uVar13 = in_s11;
  if ((param_10 != 0) &&
     (in_fpscr = in_fpscr & 0xfffffff |
                 (uint)((param_8 - param_6) * (param_4 - param_2) +
                        (param_7 - param_5) * (param_3 - param_1) < 0.0) << 0x1f,
     SUB41(in_fpscr >> 0x1f,0))) {
    fVar14 = param_5;
    fVar15 = param_8;
    param_8 = param_6;
    param_5 = param_7;
    uVar12 = in_s14;
    uVar13 = in_s15;
    in_s14 = in_s10;
    in_s15 = in_s11;
  }
  iVar7 = param_9 + 0x18;
  iVar4 = QRegion::isEmpty();
  if (iVar4 == 0) {
    puVar5 = (undefined4 *)QRegion::begin();
    puVar6 = (undefined4 *)QRegion::end();
    for (; puVar5 != puVar6; puVar5 = puVar5 + 4) {
      fVar10 = (float)VectorSignedToFloat(*puVar5,(byte)(in_fpscr >> 0x15) & 3);
      fVar8 = (float)VectorSignedToFloat(puVar5[1],(byte)(in_fpscr >> 0x15) & 3);
      uVar1 = in_fpscr & 0xfffffff;
      uVar2 = uVar1 | (uint)(fVar10 < param_1) << 0x1f | (uint)(fVar10 == param_1) << 0x1e;
      in_fpscr = uVar2 | (uint)(NAN(fVar10) || NAN(param_1)) << 0x1c;
      bVar3 = (byte)(uVar2 >> 0x18);
      fVar11 = (float)VectorSignedToFloat(puVar5[2] + 1,(byte)(in_fpscr >> 0x15) & 3);
      fVar9 = (float)VectorSignedToFloat(puVar5[3] + 1,(byte)(in_fpscr >> 0x15) & 3);
      *(float *)(param_9 + 0x1c) = fVar10;
      *(float *)(param_9 + 0x24) = fVar8;
      *(float *)(param_9 + 0x20) = fVar11;
      *(float *)(param_9 + 0x28) = fVar9;
      if (((((!(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1)) ||
            (uVar2 = uVar1 | (uint)(fVar10 < param_3) << 0x1f | (uint)(fVar10 == param_3) << 0x1e,
            in_fpscr = uVar2 | (uint)(NAN(fVar10) || NAN(param_3)) << 0x1c,
            bVar3 = (byte)(uVar2 >> 0x18),
            !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))) ||
           (in_fpscr = uVar1 | (uint)(param_5 < fVar10) << 0x1f, SUB41(in_fpscr >> 0x1f,0))) ||
          (((in_fpscr = uVar1 | (uint)(fVar11 < param_1) << 0x1f, SUB41(in_fpscr >> 0x1f,0) ||
            (in_fpscr = uVar1 | (uint)(fVar11 < param_3) << 0x1f, SUB41(in_fpscr >> 0x1f,0))) ||
           ((uVar2 = uVar1 | (uint)(param_5 < fVar11) << 0x1f | (uint)(param_5 == fVar11) << 0x1e,
            in_fpscr = uVar2 | (uint)(NAN(param_5) || NAN(fVar11)) << 0x1c,
            bVar3 = (byte)(uVar2 >> 0x18),
            !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1) ||
            ((uVar2 = uVar1 | (uint)(fVar8 < param_2) << 0x1f | (uint)(fVar8 == param_2) << 0x1e,
             in_fpscr = uVar2 | (uint)(NAN(fVar8) || NAN(param_2)) << 0x1c,
             bVar3 = (byte)(uVar2 >> 0x18),
             !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1) ||
             (uVar2 = uVar1 | (uint)(fVar8 < param_4) << 0x1f | (uint)(fVar8 == param_4) << 0x1e,
             in_fpscr = uVar2 | (uint)(NAN(fVar8) || NAN(param_4)) << 0x1c,
             bVar3 = (byte)(uVar2 >> 0x18),
             !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))))))))) ||
         ((in_fpscr = uVar1 | (uint)(fVar15 < fVar8) << 0x1f, SUB41(in_fpscr >> 0x1f,0) ||
          (((in_fpscr = uVar1 | (uint)(fVar9 < param_2) << 0x1f, SUB41(in_fpscr >> 0x1f,0) ||
            (in_fpscr = uVar1 | (uint)(fVar9 < param_4) << 0x1f, SUB41(in_fpscr >> 0x1f,0))) ||
           (uVar1 = uVar1 | (uint)(fVar15 < fVar9) << 0x1f | (uint)(fVar15 == fVar9) << 0x1e,
           in_fpscr = uVar1 | (uint)(NAN(fVar15) || NAN(fVar9)) << 0x1c,
           bVar3 = (byte)(uVar1 >> 0x18),
           !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))))))) {
        FUN_00b78f04(in_s8,in_s9,in_s12,in_s13,uVar12,uVar13,iVar7,param_1,param_2,param_3,param_4,
                     param_5,fVar15);
      }
      else {
        (**(code **)(**(int **)(param_9 + 0x18) + 8))
                  (in_s8,in_s9,in_s12,in_s13,uVar12,uVar13,*(int **)(param_9 + 0x18),param_1,param_2
                   ,param_3,param_4,param_5,fVar15);
      }
    }
  }
  else {
    FUN_00b79288(in_s8,in_s9,in_s12,in_s13,uVar12,uVar13,iVar7,param_1,param_2,param_3,param_4,
                 param_5,fVar15);
  }
  iVar4 = QRegion::isEmpty();
  if (iVar4 == 0) {
    puVar5 = (undefined4 *)QRegion::begin();
    puVar6 = (undefined4 *)QRegion::end();
    for (; puVar5 != puVar6; puVar5 = puVar5 + 4) {
      fVar10 = (float)VectorSignedToFloat(*puVar5,(byte)(in_fpscr >> 0x15) & 3);
      fVar8 = (float)VectorSignedToFloat(puVar5[1],(byte)(in_fpscr >> 0x15) & 3);
      uVar1 = in_fpscr & 0xfffffff;
      in_fpscr = uVar1 | (uint)(param_5 < fVar10) << 0x1f;
      fVar11 = (float)VectorSignedToFloat(puVar5[2] + 1,(byte)(in_fpscr >> 0x15) & 3);
      fVar9 = (float)VectorSignedToFloat(puVar5[3] + 1,(byte)(in_fpscr >> 0x15) & 3);
      *(float *)(param_9 + 0x1c) = fVar10;
      *(float *)(param_9 + 0x24) = fVar8;
      *(float *)(param_9 + 0x20) = fVar11;
      *(float *)(param_9 + 0x28) = fVar9;
      if ((((SUB41(in_fpscr >> 0x1f,0)) ||
           (uVar2 = uVar1 | (uint)(fVar10 < param_3) << 0x1f | (uint)(fVar10 == param_3) << 0x1e,
           in_fpscr = uVar2 | (uint)(NAN(fVar10) || NAN(param_3)) << 0x1c,
           bVar3 = (byte)(uVar2 >> 0x18),
           !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))) ||
          ((in_fpscr = uVar1 | (uint)(fVar14 < fVar10) << 0x1f, SUB41(in_fpscr >> 0x1f,0) ||
           ((uVar2 = uVar1 | (uint)(param_5 < fVar11) << 0x1f | (uint)(param_5 == fVar11) << 0x1e,
            in_fpscr = uVar2 | (uint)(NAN(param_5) || NAN(fVar11)) << 0x1c,
            bVar3 = (byte)(uVar2 >> 0x18),
            !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1) ||
            (in_fpscr = uVar1 | (uint)(fVar11 < param_3) << 0x1f, SUB41(in_fpscr >> 0x1f,0))))))) ||
         ((uVar2 = uVar1 | (uint)(fVar14 < fVar11) << 0x1f | (uint)(fVar14 == fVar11) << 0x1e,
          in_fpscr = uVar2 | (uint)(NAN(fVar14) || NAN(fVar11)) << 0x1c,
          bVar3 = (byte)(uVar2 >> 0x18),
          !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1) ||
          (((((in_fpscr = uVar1 | (uint)(fVar15 < fVar8) << 0x1f, SUB41(in_fpscr >> 0x1f,0) ||
              (uVar2 = uVar1 | (uint)(fVar8 < param_4) << 0x1f | (uint)(fVar8 == param_4) << 0x1e,
              in_fpscr = uVar2 | (uint)(NAN(fVar8) || NAN(param_4)) << 0x1c,
              bVar3 = (byte)(uVar2 >> 0x18),
              !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))) ||
             (in_fpscr = uVar1 | (uint)(param_8 < fVar8) << 0x1f, SUB41(in_fpscr >> 0x1f,0))) ||
            ((uVar2 = uVar1 | (uint)(fVar15 < fVar9) << 0x1f | (uint)(fVar15 == fVar9) << 0x1e,
             in_fpscr = uVar2 | (uint)(NAN(fVar15) || NAN(fVar9)) << 0x1c,
             bVar3 = (byte)(uVar2 >> 0x18),
             !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1) ||
             (in_fpscr = uVar1 | (uint)(fVar9 < param_4) << 0x1f, SUB41(in_fpscr >> 0x1f,0))))) ||
           (uVar1 = uVar1 | (uint)(param_8 < fVar9) << 0x1f | (uint)(param_8 == fVar9) << 0x1e,
           in_fpscr = uVar1 | (uint)(NAN(param_8) || NAN(fVar9)) << 0x1c,
           bVar3 = (byte)(uVar1 >> 0x18),
           !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))))))) {
        FUN_00b78f04(uVar12,uVar13,in_s12,in_s13,in_s14,in_s15,iVar7,param_5,fVar15,param_3,param_4,
                     fVar14,param_8);
      }
      else {
        (**(code **)(**(int **)(param_9 + 0x18) + 8))
                  (uVar12,uVar13,in_s12,in_s13,in_s14,in_s15,*(int **)(param_9 + 0x18),param_5,
                   fVar15,param_3,param_4,fVar14,param_8);
      }
    }
  }
  else {
    FUN_00b79288(uVar12,uVar13,in_s12,in_s13,in_s14,in_s15,iVar7,param_5,fVar15,param_3,param_4,
                 fVar14,param_8);
  }
  *(int *)(param_9 + 0x34) = *(int *)(param_9 + 0x34) + 2;
  return;
}

