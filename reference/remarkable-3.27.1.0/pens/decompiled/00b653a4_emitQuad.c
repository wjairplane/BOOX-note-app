
void FUN_00b653a4(float param_1,float param_2,float param_3,float param_4,float param_5,
                 float param_6,float param_7,float param_8,int param_9,int param_10)

{
  int *piVar1;
  uint uVar2;
  int *piVar3;
  undefined4 *puVar4;
  byte bVar5;
  int iVar6;
  undefined4 *puVar7;
  undefined4 *puVar8;
  undefined4 uVar9;
  int iVar10;
  int iVar11;
  int iVar12;
  uint in_fpscr;
  uint uVar13;
  uint uVar14;
  float fVar15;
  float fVar16;
  float fVar17;
  float fVar18;
  float fVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  float fVar23;
  float fVar24;
  float fVar25;
  float fVar26;
  undefined1 auVar27 [16];
  float local_78;
  float fStack_74;
  
  fVar24 = param_7;
  fVar25 = param_6;
  if ((param_10 != 0) &&
     (in_fpscr = in_fpscr & 0xfffffff |
                 (uint)((param_8 - param_6) * (param_4 - param_2) +
                        (param_7 - param_5) * (param_3 - param_1) < 0.0) << 0x1f,
     SUB41(in_fpscr >> 0x1f,0))) {
    fVar24 = param_5;
    fVar25 = param_8;
    param_5 = param_7;
    param_8 = param_6;
  }
  iVar11 = param_9 + 0x2c;
  iVar12 = param_9 + 0x18;
  iVar6 = QRegion::isEmpty();
  if (iVar6 == 0) {
    puVar7 = (undefined4 *)QRegion::begin();
    puVar8 = (undefined4 *)QRegion::end();
    if (puVar7 != puVar8) {
      uVar2 = in_fpscr & 0xfffffff | (uint)(param_1 < param_3) << 0x1f |
              (uint)(param_1 == param_3) << 0x1e;
      uVar13 = uVar2 | (uint)(NAN(param_1) || NAN(param_3)) << 0x1c;
      bVar5 = (byte)(uVar2 >> 0x18);
      if ((bool)(bVar5 >> 6 & 1) || bVar5 >> 7 != ((byte)(uVar13 >> 0x1c) & 1)) {
        do {
          iVar6 = puVar7[2];
          fVar16 = (float)VectorSignedToFloat(puVar7[1],(byte)(uVar13 >> 0x15) & 3);
          fVar22 = (float)VectorSignedToFloat(*puVar7,(byte)(uVar13 >> 0x15) & 3);
          iVar10 = puVar7[3];
          *(float *)(param_9 + 0x24) = fVar16;
          uVar2 = uVar13 & 0xfffffff;
          uVar13 = uVar2 | (uint)(param_1 < fVar22) << 0x1f;
          fVar20 = (float)VectorSignedToFloat(iVar6 + 1,(byte)(uVar13 >> 0x15) & 3);
          *(float *)(param_9 + 0x1c) = fVar22;
          *(float *)(param_9 + 0x20) = fVar20;
          fVar18 = (float)VectorSignedToFloat(iVar10 + 1,(byte)(uVar13 >> 0x15) & 3);
          *(float *)(param_9 + 0x28) = fVar18;
          if ((((((SUB41(uVar13 >> 0x1f,0)) ||
                 (uVar13 = uVar2 | (uint)(param_3 < fVar22) << 0x1f, SUB41(uVar13 >> 0x1f,0))) ||
                (uVar13 = uVar2 | (uint)(param_5 < fVar22) << 0x1f, SUB41(uVar13 >> 0x1f,0))) ||
               ((uVar14 = uVar2 | (uint)(param_1 < fVar20) << 0x1f |
                          (uint)(param_1 == fVar20) << 0x1e,
                uVar13 = uVar14 | (uint)(NAN(param_1) || NAN(fVar20)) << 0x1c,
                bVar5 = (byte)(uVar14 >> 0x18),
                !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1) ||
                (uVar14 = uVar2 | (uint)(param_3 < fVar20) << 0x1f |
                          (uint)(param_3 == fVar20) << 0x1e,
                uVar13 = uVar14 | (uint)(NAN(param_3) || NAN(fVar20)) << 0x1c,
                bVar5 = (byte)(uVar14 >> 0x18),
                !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1))))) ||
              (uVar14 = uVar2 | (uint)(param_5 < fVar20) << 0x1f | (uint)(param_5 == fVar20) << 0x1e
              , uVar13 = uVar14 | (uint)(NAN(param_5) || NAN(fVar20)) << 0x1c,
              bVar5 = (byte)(uVar14 >> 0x18),
              !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1))) ||
             (((uVar13 = uVar2 | (uint)(param_2 < fVar16) << 0x1f, SUB41(uVar13 >> 0x1f,0) ||
               (uVar13 = uVar2 | (uint)(param_4 < fVar16) << 0x1f, SUB41(uVar13 >> 0x1f,0))) ||
              ((uVar13 = uVar2 | (uint)(fVar25 < fVar16) << 0x1f, SUB41(uVar13 >> 0x1f,0) ||
               (((uVar14 = uVar2 | (uint)(param_2 < fVar18) << 0x1f |
                           (uint)(param_2 == fVar18) << 0x1e,
                 uVar13 = uVar14 | (uint)(NAN(param_2) || NAN(fVar18)) << 0x1c,
                 bVar5 = (byte)(uVar14 >> 0x18),
                 !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1) ||
                 (uVar14 = uVar2 | (uint)(param_4 < fVar18) << 0x1f |
                           (uint)(param_4 == fVar18) << 0x1e,
                 uVar13 = uVar14 | (uint)(NAN(param_4) || NAN(fVar18)) << 0x1c,
                 bVar5 = (byte)(uVar14 >> 0x18),
                 !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1))) ||
                (uVar2 = uVar2 | (uint)(fVar25 < fVar18) << 0x1f | (uint)(fVar25 == fVar18) << 0x1e,
                uVar13 = uVar2 | (uint)(NAN(fVar25) || NAN(fVar18)) << 0x1c,
                bVar5 = (byte)(uVar2 >> 0x18),
                !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1))))))))) {
            if (param_1 == param_5 || param_1 < param_5 != (NAN(param_1) || NAN(param_5))) {
              uVar13 = uVar13 & 0xfffffff | (uint)(param_3 < param_5) << 0x1f |
                       (uint)(param_3 == param_5) << 0x1e;
              bVar5 = (byte)(uVar13 >> 0x18);
              fVar16 = param_2;
              fVar18 = param_1;
              fVar20 = param_5;
              fVar26 = fVar25;
              fVar23 = param_5;
              fVar21 = fVar25;
              if (!(bool)(bVar5 >> 6 & 1) && (bool)(bVar5 >> 7) == (NAN(param_3) || NAN(param_5)))
              goto LAB_00b65abc;
LAB_00b65a58:
              uVar13 = uVar13 & 0xfffffff | (uint)(fVar22 < fVar18) << 0x1f;
              bVar5 = (byte)(uVar13 >> 0x18);
              fVar20 = param_3;
              fVar26 = param_4;
            }
            else {
              uVar13 = uVar13 & 0xfffffff | (uint)(param_3 < param_1) << 0x1f |
                       (uint)(param_3 == param_1) << 0x1e;
              bVar5 = (byte)(uVar13 >> 0x18);
              fVar16 = fVar25;
              fVar18 = param_5;
              fVar20 = param_1;
              fVar26 = param_2;
              fVar23 = param_1;
              fVar21 = param_2;
              if ((bool)(bVar5 >> 6 & 1) || (bool)(bVar5 >> 7) != (NAN(param_3) || NAN(param_1)))
              goto LAB_00b65a58;
LAB_00b65abc:
              uVar13 = uVar13 & 0xfffffff | (uint)(fVar22 < fVar18) << 0x1f;
              bVar5 = (byte)(uVar13 >> 0x18);
              fVar23 = param_3;
              fVar21 = param_4;
            }
            if ((bool)(bVar5 >> 7)) {
              FUN_00b64e80(iVar12,fVar18,fVar16,param_3,param_4,fVar20,fVar26);
            }
            else {
              uVar2 = uVar13 & 0xfffffff;
              uVar14 = uVar2 | (uint)(fVar20 < fVar22) << 0x1f | (uint)(fVar20 == fVar22) << 0x1e;
              uVar13 = uVar14 | (uint)(NAN(fVar20) || NAN(fVar22)) << 0x1c;
              bVar5 = (byte)(uVar14 >> 0x18);
              if ((bool)(bVar5 >> 6 & 1) || bVar5 >> 7 != ((byte)(uVar13 >> 0x1c) & 1)) {
                uVar2 = uVar2 | (uint)(fVar23 < fVar22) << 0x1f | (uint)(fVar23 == fVar22) << 0x1e;
                uVar13 = uVar2 | (uint)(NAN(fVar23) || NAN(fVar22)) << 0x1c;
                bVar5 = (byte)(uVar2 >> 0x18);
                if (!(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1)) {
                  FUN_00b64e80(iVar12,fVar22,
                               fVar21 + ((fVar22 - fVar23) / (fVar18 - fVar23)) * (fVar16 - fVar21),
                               local_78,fStack_74,fVar22,
                               fVar21 + ((fVar22 - fVar23) / (fVar20 - fVar23)) * (fVar26 - fVar21))
                  ;
                }
              }
              else {
                fVar23 = fVar16 + ((fVar22 - fVar18) / (fVar23 - fVar18)) * (fVar21 - fVar16);
                FUN_00b64e80(iVar12,fVar22,
                             fVar16 + ((fVar22 - fVar18) / (fVar20 - fVar18)) * (fVar26 - fVar16),
                             local_78,fStack_74,fVar22,fVar23);
                FUN_00b64e80(iVar12,*(undefined4 *)(param_9 + 0x1c),fVar23,local_78,fStack_74,fVar20
                             ,fVar26);
              }
            }
          }
          else {
            (**(code **)(**(int **)(param_9 + 0x18) + 8))
                      (*(int **)(param_9 + 0x18),param_1,param_2,param_3,param_4,param_5,fVar25,0,0,
                       0,fVar24,iVar11);
            local_78 = param_3;
            fStack_74 = param_4;
          }
          puVar7 = puVar7 + 4;
        } while (puVar8 != puVar7);
      }
      else {
        do {
          iVar6 = puVar7[2];
          fVar15 = (float)VectorSignedToFloat(puVar7[1],(byte)(uVar13 >> 0x15) & 3);
          fVar21 = (float)VectorSignedToFloat(*puVar7,(byte)(uVar13 >> 0x15) & 3);
          iVar11 = puVar7[3];
          *(float *)(param_9 + 0x24) = fVar15;
          uVar2 = uVar13 & 0xfffffff;
          uVar13 = uVar2 | (uint)(param_1 < fVar21) << 0x1f;
          fVar19 = (float)VectorSignedToFloat(iVar6 + 1,(byte)(uVar13 >> 0x15) & 3);
          *(float *)(param_9 + 0x1c) = fVar21;
          *(float *)(param_9 + 0x20) = fVar19;
          fVar17 = (float)VectorSignedToFloat(iVar11 + 1,(byte)(uVar13 >> 0x15) & 3);
          *(float *)(param_9 + 0x28) = fVar17;
          fVar16 = fVar25;
          fVar18 = param_5;
          fVar20 = param_3;
          fVar22 = param_1;
          fVar26 = param_4;
          fVar23 = param_2;
          if ((SUB41(uVar13 >> 0x1f,0)) ||
             (uVar13 = uVar2 | (uint)(param_3 < fVar21) << 0x1f, SUB41(uVar13 >> 0x1f,0))) {
LAB_00b656cc:
            uVar13 = uVar13 & 0xfffffff;
            uVar2 = uVar13 | (uint)(param_3 < param_5) << 0x1f | (uint)(param_3 == param_5) << 0x1e;
            uVar14 = uVar2 | (uint)(NAN(param_3) || NAN(param_5)) << 0x1c;
            bVar5 = (byte)(uVar2 >> 0x18);
            if (((bool)(bVar5 >> 6 & 1) || bVar5 >> 7 != ((byte)(uVar14 >> 0x1c) & 1)) &&
               (uVar2 = uVar13 | (uint)(param_1 < param_5) << 0x1f |
                        (uint)(param_1 == param_5) << 0x1e,
               uVar14 = uVar2 | (uint)(NAN(param_1) || NAN(param_5)) << 0x1c,
               bVar5 = (byte)(uVar2 >> 0x18), fVar16 = param_4, fVar18 = param_3, fVar20 = param_5,
               fVar26 = fVar25, (bool)(bVar5 >> 6 & 1) || bVar5 >> 7 != ((byte)(uVar14 >> 0x1c) & 1)
               )) {
              uVar2 = uVar13 | (uint)(param_3 < fVar21) << 0x1f | (uint)(param_3 == fVar21) << 0x1e;
              uVar13 = uVar2 | (uint)(NAN(param_3) || NAN(fVar21)) << 0x1c;
              bVar5 = (byte)(uVar2 >> 0x18);
              fVar20 = param_1;
              fVar22 = param_5;
              fVar26 = param_2;
              fVar23 = fVar25;
              if ((bool)(bVar5 >> 6 & 1) || bVar5 >> 7 != ((byte)(uVar13 >> 0x1c) & 1))
              goto LAB_00b65714;
            }
            else {
              uVar2 = uVar14 & 0xfffffff | (uint)(fVar18 < fVar21) << 0x1f |
                      (uint)(fVar18 == fVar21) << 0x1e;
              uVar13 = uVar2 | (uint)(NAN(fVar18) || NAN(fVar21)) << 0x1c;
              bVar5 = (byte)(uVar2 >> 0x18);
              if ((bool)(bVar5 >> 6 & 1) || bVar5 >> 7 != ((byte)(uVar13 >> 0x1c) & 1)) {
LAB_00b65714:
                uVar2 = uVar13 & 0xfffffff;
                uVar13 = uVar2 | (uint)(fVar21 < fVar20) << 0x1f;
                if (SUB41(uVar13 >> 0x1f,0)) {
                  fVar15 = fVar16 + ((fVar21 - fVar18) / (fVar22 - fVar18)) * (fVar23 - fVar16);
                  FUN_00b64e80(iVar12,fVar21,
                               fVar16 + ((fVar21 - fVar18) / (fVar20 - fVar18)) * (fVar26 - fVar16),
                               local_78,fStack_74,fVar21,fVar15);
                  fVar21 = *(float *)(param_9 + 0x1c);
                }
                else {
                  uVar13 = uVar2 | (uint)(fVar21 < fVar22) << 0x1f;
                  if (!SUB41(uVar13 >> 0x1f,0)) goto LAB_00b6572c;
                  fVar15 = fVar23 + ((fVar21 - fVar22) / (fVar18 - fVar22)) * (fVar16 - fVar23);
                  fVar26 = fVar23 + ((fVar21 - fVar22) / (fVar20 - fVar22)) * (fVar26 - fVar23);
                  fVar20 = fVar21;
                }
                FUN_00b64e80(iVar12,fVar21,fVar15,local_78,fStack_74,fVar20,fVar26);
                goto LAB_00b6572c;
              }
            }
            FUN_00b64e80(iVar12,fVar18,fVar16,param_3,param_4,fVar20,fVar26);
          }
          else {
            uVar13 = uVar2 | (uint)(param_5 < fVar21) << 0x1f;
            if (SUB41(uVar13 >> 0x1f,0)) goto LAB_00b65714;
            uVar14 = uVar2 | (uint)(param_1 < fVar19) << 0x1f | (uint)(param_1 == fVar19) << 0x1e;
            uVar13 = uVar14 | (uint)(NAN(param_1) || NAN(fVar19)) << 0x1c;
            bVar5 = (byte)(uVar14 >> 0x18);
            if ((((!(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1)) ||
                 (uVar14 = uVar2 | (uint)(param_3 < fVar19) << 0x1f |
                           (uint)(param_3 == fVar19) << 0x1e,
                 uVar13 = uVar14 | (uint)(NAN(param_3) || NAN(fVar19)) << 0x1c,
                 bVar5 = (byte)(uVar14 >> 0x18),
                 !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1))) ||
                ((uVar14 = uVar2 | (uint)(param_5 < fVar19) << 0x1f |
                           (uint)(param_5 == fVar19) << 0x1e,
                 uVar13 = uVar14 | (uint)(NAN(param_5) || NAN(fVar19)) << 0x1c,
                 bVar5 = (byte)(uVar14 >> 0x18),
                 !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1) ||
                 (((uVar13 = uVar2 | (uint)(param_2 < fVar15) << 0x1f, SUB41(uVar13 >> 0x1f,0) ||
                   (uVar13 = uVar2 | (uint)(param_4 < fVar15) << 0x1f, SUB41(uVar13 >> 0x1f,0))) ||
                  (uVar13 = uVar2 | (uint)(fVar25 < fVar15) << 0x1f, SUB41(uVar13 >> 0x1f,0)))))))
               || (((uVar14 = uVar2 | (uint)(param_2 < fVar17) << 0x1f |
                              (uint)(param_2 == fVar17) << 0x1e,
                    uVar13 = uVar14 | (uint)(NAN(param_2) || NAN(fVar17)) << 0x1c,
                    bVar5 = (byte)(uVar14 >> 0x18),
                    !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1) ||
                    (uVar14 = uVar2 | (uint)(param_4 < fVar17) << 0x1f |
                              (uint)(param_4 == fVar17) << 0x1e,
                    uVar13 = uVar14 | (uint)(NAN(param_4) || NAN(fVar17)) << 0x1c,
                    bVar5 = (byte)(uVar14 >> 0x18),
                    !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1))) ||
                   (uVar2 = uVar2 | (uint)(fVar25 < fVar17) << 0x1f |
                            (uint)(fVar25 == fVar17) << 0x1e,
                   uVar13 = uVar2 | (uint)(NAN(fVar25) || NAN(fVar17)) << 0x1c,
                   bVar5 = (byte)(uVar2 >> 0x18),
                   !(bool)(bVar5 >> 6 & 1) && bVar5 >> 7 == ((byte)(uVar13 >> 0x1c) & 1)))))
            goto LAB_00b656cc;
            (**(code **)(**(int **)(param_9 + 0x18) + 8))
                      (*(int **)(param_9 + 0x18),param_1,param_2,param_3,param_4,param_5,fVar25,0,0,
                       0,fVar24);
            local_78 = param_3;
            fStack_74 = param_4;
          }
LAB_00b6572c:
          puVar7 = puVar7 + 4;
        } while (puVar8 != puVar7);
      }
    }
  }
  else {
    FUN_00b65034(iVar12,param_1,param_2,param_3,param_4,param_5,fVar25);
  }
  iVar6 = QRegion::isEmpty();
  if (iVar6 == 0) {
    puVar7 = (undefined4 *)QRegion::begin();
    puVar8 = (undefined4 *)QRegion::end();
    if (puVar7 != puVar8) {
      do {
        piVar1 = puVar7 + 2;
        piVar3 = puVar7 + 3;
        uVar9 = *puVar7;
        puVar4 = puVar7 + 1;
        puVar7 = puVar7 + 4;
        auVar27._4_4_ = *piVar1 + 1;
        auVar27._0_4_ = uVar9;
        auVar27._8_4_ = *puVar4;
        auVar27._12_4_ = *piVar3 + 1;
        auVar27 = VectorSignedToFloat(auVar27,8);
        *(longlong *)(param_9 + 0x1c) = auVar27._0_8_;
        *(longlong *)(param_9 + 0x24) = auVar27._8_8_;
        FUN_00b65034(iVar12,param_5,fVar25,param_3,param_4,fVar24,param_8);
      } while (puVar8 != puVar7);
    }
  }
  else {
    FUN_00b65034(iVar12,param_5,fVar25,param_3,param_4,fVar24,param_8);
  }
  *(int *)(param_9 + 0x34) = *(int *)(param_9 + 0x34) + 2;
  return;
}

