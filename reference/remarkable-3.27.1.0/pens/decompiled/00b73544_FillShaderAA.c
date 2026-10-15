
void FUN_00b73544(int param_1,float param_2,float param_3,float param_4)

{
  uint uVar1;
  void *pvVar2;
  uint uVar3;
  uint uVar4;
  size_t sVar5;
  uint *puVar6;
  uint *puVar7;
  byte *pbVar8;
  code *pcVar9;
  int *piVar10;
  uint uVar11;
  uint uVar12;
  uint *puVar13;
  uint uVar14;
  float fVar15;
  float fVar16;
  uint uVar17;
  uint uVar18;
  uint uVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  float fVar23;
  float fVar24;
  float fVar25;
  float fVar26;
  float fVar27;
  float fVar28;
  float fStack00000004;
  float fStack00000008;
  float fStack0000000c;
  float in_stack_00000010;
  float in_stack_00000014;
  float in_stack_00000018;
  
  fVar20 = param_2;
  fVar24 = param_3;
  if (in_stack_00000010 < param_3) {
    fVar25 = param_4;
    fVar23 = param_2;
    fVar26 = param_3;
    if (in_stack_00000010 == in_stack_00000018 ||
        in_stack_00000010 < in_stack_00000018 != (NAN(in_stack_00000010) || NAN(in_stack_00000018)))
    goto LAB_00b7358c;
  }
  else {
    fVar25 = param_2;
    fVar23 = param_4;
    fVar15 = in_stack_00000014;
    fVar26 = in_stack_00000010;
    fVar16 = in_stack_00000018;
    in_stack_00000010 = param_3;
    if (param_3 == in_stack_00000018 ||
        param_3 < in_stack_00000018 != (NAN(param_3) || NAN(in_stack_00000018))) {
LAB_00b7358c:
      fVar15 = fVar25;
      fVar16 = in_stack_00000010;
      fVar24 = in_stack_00000018;
      fVar20 = in_stack_00000014;
    }
    in_stack_00000018 = fVar16;
    in_stack_00000014 = fVar15;
    fVar25 = fVar23;
    in_stack_00000010 = fVar26;
    if (fVar24 < fVar26) {
      fVar25 = fVar20;
      in_stack_00000010 = fVar24;
      fVar20 = fVar23;
      fVar24 = fVar26;
    }
  }
  fStack00000004 = param_2;
  fStack00000008 = param_3;
  fStack0000000c = param_4;
  fVar15 = floorf(in_stack_00000018);
  fVar26 = DAT_00b738b4;
  fVar23 = DAT_00b738b0;
  fVar16 = 0.5;
  if (0.5 < in_stack_00000018 - fVar15) {
    fVar16 = 1.5;
  }
  fVar15 = fVar15 + fVar16;
  if (in_stack_00000010 != in_stack_00000018) {
    fVar27 = (fVar25 - in_stack_00000014) / (in_stack_00000010 - in_stack_00000018);
    fVar28 = (fVar20 - in_stack_00000014) / (fVar24 - in_stack_00000018);
    fVar22 = in_stack_00000014 + fVar27 * (fVar15 - in_stack_00000018) + 0.5;
    fVar16 = in_stack_00000014 + fVar28 * (fVar15 - in_stack_00000018) + 0.5;
    if (fVar27 == fVar28 || fVar27 < fVar28 != (NAN(fVar27) || NAN(fVar28))) {
      fVar21 = fVar22;
      fVar22 = fVar27;
      if (in_stack_00000010 == fVar15 ||
          in_stack_00000010 < fVar15 != (NAN(in_stack_00000010) || NAN(fVar15))) goto LAB_00b73838;
    }
    else {
      fVar21 = fVar16;
      fVar16 = fVar22;
      fVar22 = fVar28;
      fVar28 = fVar27;
      if (in_stack_00000010 == fVar15 ||
          in_stack_00000010 < fVar15 != (NAN(in_stack_00000010) || NAN(fVar15))) goto LAB_00b73838;
    }
    do {
      uVar17 = (uint)fVar21;
      uVar18 = (uint)fVar16;
      if (((int)uVar17 < (int)uVar18) && (uVar19 = (uint)fVar15, uVar17 < uVar18)) {
        uVar12 = uVar19 & 0xffffffe0;
        do {
          piVar10 = *(int **)(param_1 + 4);
          fVar27 = *(float *)(param_1 + 8) + *(float *)(param_1 + 0xc) * fVar23;
          puVar13 = (uint *)piVar10[2];
          uVar4 = uVar17 & 0xffffffe0;
          if (fVar27 < 1.0) {
            uVar11 = VectorFloatToUnsigned(fVar27 * fVar26,3);
            uVar11 = uVar11 & 0xff;
          }
          else {
            uVar11 = 0xff;
          }
          if (puVar13 == (uint *)0x0) {
            puVar13 = (uint *)piVar10[5];
            if (puVar13 == (uint *)0x0) {
              puVar13 = (uint *)malloc(0x410);
            }
            else {
              piVar10[5] = puVar13[2];
              piVar10[6] = piVar10[6] + -1;
            }
            *puVar13 = uVar4;
            puVar13[1] = uVar12;
            uVar3 = piVar10[4];
            sVar5 = piVar10[3] - uVar4;
            pcVar9 = *(code **)(*piVar10 + 8);
            uVar1 = uVar3 - uVar12;
            if (0x1f < sVar5) {
              sVar5 = 0x20;
            }
            if (0x1f < uVar1) {
              uVar1 = 0x20;
            }
            puVar13[2] = 0;
            puVar13[3] = 0;
            if (pcVar9 == FUN_00b6d408) {
              uVar14 = uVar12;
              if (uVar3 != uVar12) {
                uVar4 = 0;
                puVar7 = puVar13 + 4;
                do {
                  uVar4 = uVar4 + 1;
                  memset(puVar7,0,sVar5);
                  puVar7 = puVar7 + 8;
                } while (uVar4 < uVar1);
                uVar4 = *puVar13;
                uVar14 = puVar13[1];
              }
            }
            else {
              (*pcVar9)(piVar10,puVar13 + 4,uVar4,uVar12,sVar5,uVar1,0x20);
              uVar4 = *puVar13;
              uVar14 = puVar13[1];
            }
            *(ulonglong *)(piVar10 + 1) = CONCAT44(puVar13,puVar13);
            pbVar8 = (byte *)((int)puVar13 + ((uVar17 + 0x10) - uVar4) + (uVar19 - uVar14) * 0x20);
          }
          else {
            uVar1 = puVar13[1];
            if (uVar4 == *puVar13) {
              if (uVar12 != uVar1) {
                if (uVar1 < uVar12) goto LAB_00b73d0c;
                goto LAB_00b73704;
              }
              pbVar8 = (byte *)((int)puVar13 + (0x10 - uVar4) + (uVar19 - uVar12) * 0x20 + uVar17);
            }
            else if ((uVar1 < uVar12) || (uVar12 == uVar1 && *puVar13 < uVar4)) {
LAB_00b73d0c:
              for (puVar7 = (uint *)puVar13[2]; puVar7 != (uint *)0x0; puVar7 = (uint *)puVar7[2]) {
                uVar1 = puVar7[1];
                if ((uVar12 <= uVar1) && ((uVar1 != uVar12 || (uVar4 <= *puVar7)))) {
                  uVar3 = uVar12;
                  if ((uVar4 == *puVar7) && (uVar1 == uVar12)) {
                    piVar10[2] = (int)puVar7;
                  }
                  else {
                    puVar7 = (uint *)piVar10[5];
                    if (puVar7 == (uint *)0x0) {
                      puVar7 = (uint *)malloc(0x410);
                    }
                    else {
                      piVar10[5] = puVar7[2];
                      piVar10[6] = piVar10[6] + -1;
                    }
                    *puVar7 = uVar4;
                    puVar7[1] = uVar12;
                    uVar14 = piVar10[4];
                    sVar5 = piVar10[3] - uVar4;
                    pcVar9 = *(code **)(*piVar10 + 8);
                    uVar1 = uVar14 - uVar12;
                    if (0x1f < sVar5) {
                      sVar5 = 0x20;
                    }
                    if (0x1f < uVar1) {
                      uVar1 = 0x20;
                    }
                    puVar6 = puVar7 + 4;
                    puVar7[2] = 0;
                    puVar7[3] = 0;
                    if (pcVar9 == FUN_00b6d408) {
                      if (uVar14 != uVar12) {
                        uVar4 = 0;
                        do {
                          uVar4 = uVar4 + 1;
                          pvVar2 = memset(puVar6,0,sVar5);
                          puVar6 = (uint *)((int)pvVar2 + 0x20);
                        } while (uVar4 < uVar1);
                        uVar4 = *puVar7;
                        uVar3 = puVar7[1];
                      }
                    }
                    else {
                      (*pcVar9)(piVar10,puVar6,uVar4,uVar12,sVar5,uVar1,0x20);
                      uVar4 = *puVar7;
                      uVar3 = puVar7[1];
                    }
                    uVar1 = puVar13[2];
                    puVar7[3] = (uint)puVar13;
                    puVar7[2] = uVar1;
                    *(uint **)(puVar13[2] + 0xc) = puVar7;
                    puVar13[2] = (uint)puVar7;
                    piVar10[2] = (int)puVar7;
                  }
                  goto LAB_00b73dfc;
                }
                puVar13 = puVar7;
              }
              puVar7 = (uint *)FUN_00b7172c(piVar10,uVar4,uVar12);
              puVar13[2] = (uint)puVar7;
              puVar7[3] = (uint)puVar13;
              uVar4 = *puVar7;
              uVar3 = puVar7[1];
              piVar10[2] = (int)puVar7;
LAB_00b73dfc:
              pbVar8 = (byte *)((int)puVar7 + ((uVar17 + 0x10) - uVar4) + (uVar19 - uVar3) * 0x20);
            }
            else {
LAB_00b73704:
              for (puVar7 = (uint *)puVar13[3]; puVar7 != (uint *)0x0; puVar7 = (uint *)puVar7[3]) {
                uVar1 = puVar7[1];
                if ((uVar1 < uVar12 || uVar1 == uVar12) && ((uVar1 != uVar12 || (*puVar7 <= uVar4)))
                   ) {
                  uVar3 = uVar12;
                  if ((uVar4 == *puVar7) && (uVar1 == uVar12)) {
                    piVar10[2] = (int)puVar7;
                  }
                  else {
                    puVar7 = (uint *)piVar10[5];
                    if (puVar7 == (uint *)0x0) {
                      puVar7 = (uint *)malloc(0x410);
                    }
                    else {
                      piVar10[5] = puVar7[2];
                      piVar10[6] = piVar10[6] + -1;
                    }
                    *puVar7 = uVar4;
                    puVar7[1] = uVar12;
                    uVar14 = piVar10[4];
                    sVar5 = piVar10[3] - uVar4;
                    pcVar9 = *(code **)(*piVar10 + 8);
                    uVar1 = uVar14 - uVar12;
                    if (0x1f < sVar5) {
                      sVar5 = 0x20;
                    }
                    if (0x1f < uVar1) {
                      uVar1 = 0x20;
                    }
                    puVar6 = puVar7 + 4;
                    puVar7[2] = 0;
                    puVar7[3] = 0;
                    if (pcVar9 == FUN_00b6d408) {
                      if (uVar14 != uVar12) {
                        uVar4 = 0;
                        do {
                          uVar4 = uVar4 + 1;
                          pvVar2 = memset(puVar6,0,sVar5);
                          puVar6 = (uint *)((int)pvVar2 + 0x20);
                        } while (uVar4 < uVar1);
                        uVar4 = *puVar7;
                        uVar3 = puVar7[1];
                      }
                    }
                    else {
                      (*pcVar9)(piVar10,puVar6,uVar4,uVar12,sVar5,uVar1,0x20);
                      uVar4 = *puVar7;
                      uVar3 = puVar7[1];
                    }
                    puVar7[2] = (uint)puVar13;
                    uVar1 = puVar13[3];
                    puVar7[3] = uVar1;
                    *(uint **)(uVar1 + 8) = puVar7;
                    puVar13[3] = (uint)puVar7;
                    piVar10[2] = (int)puVar7;
                  }
                  goto LAB_00b737f8;
                }
                puVar13 = puVar7;
              }
              puVar7 = (uint *)FUN_00b7172c(piVar10,uVar4,uVar12);
              puVar13[3] = (uint)puVar7;
              puVar7[2] = (uint)puVar13;
              uVar4 = *puVar7;
              *(ulonglong *)(piVar10 + 1) = CONCAT44(puVar7,puVar7);
              uVar3 = puVar7[1];
LAB_00b737f8:
              pbVar8 = (byte *)((int)puVar7 + ((uVar17 + 0x10) - uVar4) + (uVar19 - uVar3) * 0x20);
            }
          }
          uVar17 = uVar17 + 1;
          if (*pbVar8 < uVar11) {
            *pbVar8 = (byte)uVar11;
          }
        } while (uVar17 < uVar18);
      }
      fVar15 = fVar15 + 1.0;
      fVar21 = fVar21 + fVar22;
      fVar16 = fVar16 + fVar28;
    } while (fVar15 < in_stack_00000010);
  }
LAB_00b73838:
  fVar26 = DAT_00b738b4;
  fVar23 = DAT_00b738b0;
  if (fVar24 != in_stack_00000010) {
    fVar25 = (fVar20 - fVar25) / (fVar24 - in_stack_00000010);
    fVar28 = (fVar20 - in_stack_00000014) / (fVar24 - in_stack_00000018);
    fVar16 = (fVar20 - fVar25 * (fVar24 - fVar15)) + 0.5;
    fVar20 = (fVar20 - fVar28 * (fVar24 - fVar15)) + 0.5;
    if (fVar16 == fVar20 || fVar16 < fVar20 != (NAN(fVar16) || NAN(fVar20))) {
      fVar22 = fVar16;
      fVar16 = fVar28;
      if (fVar24 == fVar15 || fVar24 < fVar15 != (NAN(fVar24) || NAN(fVar15))) {
        return;
      }
    }
    else {
      fVar22 = fVar20;
      fVar20 = fVar16;
      fVar16 = fVar25;
      fVar25 = fVar28;
      if (fVar24 == fVar15 || fVar24 < fVar15 != (NAN(fVar24) || NAN(fVar15))) {
        return;
      }
    }
    do {
      uVar17 = (uint)fVar22;
      uVar18 = (uint)fVar20;
      if (((int)uVar17 < (int)uVar18) && (uVar19 = (uint)fVar15, uVar17 < uVar18)) {
        uVar12 = uVar19 & 0xffffffe0;
        do {
          piVar10 = *(int **)(param_1 + 4);
          fVar28 = *(float *)(param_1 + 8) + *(float *)(param_1 + 0xc) * fVar23;
          puVar13 = (uint *)piVar10[2];
          uVar4 = uVar17 & 0xffffffe0;
          if (fVar28 < 1.0) {
            uVar11 = VectorFloatToUnsigned(fVar28 * fVar26,3);
            uVar11 = uVar11 & 0xff;
          }
          else {
            uVar11 = 0xff;
          }
          if (puVar13 == (uint *)0x0) {
            puVar13 = (uint *)piVar10[5];
            if (puVar13 == (uint *)0x0) {
              puVar13 = (uint *)malloc(0x410);
            }
            else {
              piVar10[5] = puVar13[2];
              piVar10[6] = piVar10[6] + -1;
            }
            *puVar13 = uVar4;
            puVar13[1] = uVar12;
            uVar3 = piVar10[4];
            sVar5 = piVar10[3] - uVar4;
            pcVar9 = *(code **)(*piVar10 + 8);
            uVar1 = uVar3 - uVar12;
            if (0x1f < sVar5) {
              sVar5 = 0x20;
            }
            if (0x1f < uVar1) {
              uVar1 = 0x20;
            }
            puVar13[2] = 0;
            puVar13[3] = 0;
            if (pcVar9 == FUN_00b6d408) {
              uVar14 = uVar12;
              if (uVar3 != uVar12) {
                uVar4 = 0;
                puVar7 = puVar13 + 4;
                do {
                  uVar4 = uVar4 + 1;
                  memset(puVar7,0,sVar5);
                  puVar7 = puVar7 + 8;
                } while (uVar4 < uVar1);
                uVar4 = *puVar13;
                uVar14 = puVar13[1];
              }
            }
            else {
              (*pcVar9)(piVar10,puVar13 + 4,uVar4,uVar12,sVar5,uVar1,0x20);
              uVar4 = *puVar13;
              uVar14 = puVar13[1];
            }
            *(ulonglong *)(piVar10 + 1) = CONCAT44(puVar13,puVar13);
            pbVar8 = (byte *)((int)puVar13 + ((uVar17 + 0x10) - uVar4) + (uVar19 - uVar14) * 0x20);
          }
          else {
            uVar1 = puVar13[1];
            if (uVar4 == *puVar13) {
              if (uVar12 != uVar1) {
                if (uVar1 < uVar12) goto LAB_00b73bb4;
                goto LAB_00b73974;
              }
              pbVar8 = (byte *)((int)puVar13 + (0x10 - uVar4) + (uVar19 - uVar12) * 0x20 + uVar17);
            }
            else if ((uVar1 < uVar12) || (*puVar13 < uVar4 && uVar12 == uVar1)) {
LAB_00b73bb4:
              for (puVar7 = (uint *)puVar13[2]; puVar7 != (uint *)0x0; puVar7 = (uint *)puVar7[2]) {
                uVar1 = puVar7[1];
                if ((uVar12 <= uVar1) && ((uVar1 != uVar12 || (uVar4 <= *puVar7)))) {
                  uVar3 = uVar12;
                  if ((uVar4 == *puVar7) && (uVar1 == uVar12)) {
                    piVar10[2] = (int)puVar7;
                  }
                  else {
                    puVar7 = (uint *)piVar10[5];
                    if (puVar7 == (uint *)0x0) {
                      puVar7 = (uint *)malloc(0x410);
                    }
                    else {
                      piVar10[5] = puVar7[2];
                      piVar10[6] = piVar10[6] + -1;
                    }
                    *puVar7 = uVar4;
                    puVar7[1] = uVar12;
                    uVar14 = piVar10[4];
                    sVar5 = piVar10[3] - uVar4;
                    pcVar9 = *(code **)(*piVar10 + 8);
                    uVar1 = uVar14 - uVar12;
                    if (0x1f < sVar5) {
                      sVar5 = 0x20;
                    }
                    if (0x1f < uVar1) {
                      uVar1 = 0x20;
                    }
                    puVar6 = puVar7 + 4;
                    puVar7[2] = 0;
                    puVar7[3] = 0;
                    if (pcVar9 == FUN_00b6d408) {
                      if (uVar14 != uVar12) {
                        uVar4 = 0;
                        do {
                          uVar4 = uVar4 + 1;
                          pvVar2 = memset(puVar6,0,sVar5);
                          puVar6 = (uint *)((int)pvVar2 + 0x20);
                        } while (uVar4 < uVar1);
                        uVar4 = *puVar7;
                        uVar3 = puVar7[1];
                      }
                    }
                    else {
                      (*pcVar9)(piVar10,puVar6,uVar4,uVar12,sVar5,uVar1,0x20);
                      uVar4 = *puVar7;
                      uVar3 = puVar7[1];
                    }
                    uVar1 = puVar13[2];
                    puVar7[3] = (uint)puVar13;
                    puVar7[2] = uVar1;
                    *(uint **)(puVar13[2] + 0xc) = puVar7;
                    puVar13[2] = (uint)puVar7;
                    piVar10[2] = (int)puVar7;
                  }
                  goto LAB_00b73ca4;
                }
                puVar13 = puVar7;
              }
              puVar7 = (uint *)FUN_00b7172c(piVar10,uVar4,uVar12);
              puVar13[2] = (uint)puVar7;
              puVar7[3] = (uint)puVar13;
              uVar4 = *puVar7;
              uVar3 = puVar7[1];
              piVar10[2] = (int)puVar7;
LAB_00b73ca4:
              pbVar8 = (byte *)((int)puVar7 + ((uVar17 + 0x10) - uVar4) + (uVar19 - uVar3) * 0x20);
            }
            else {
LAB_00b73974:
              for (puVar7 = (uint *)puVar13[3]; puVar7 != (uint *)0x0; puVar7 = (uint *)puVar7[3]) {
                uVar1 = puVar7[1];
                if ((uVar1 < uVar12 || uVar1 == uVar12) && ((uVar1 != uVar12 || (*puVar7 <= uVar4)))
                   ) {
                  uVar3 = uVar12;
                  if ((uVar4 == *puVar7) && (uVar1 == uVar12)) {
                    piVar10[2] = (int)puVar7;
                  }
                  else {
                    puVar7 = (uint *)piVar10[5];
                    if (puVar7 == (uint *)0x0) {
                      puVar7 = (uint *)malloc(0x410);
                    }
                    else {
                      piVar10[5] = puVar7[2];
                      piVar10[6] = piVar10[6] + -1;
                    }
                    *puVar7 = uVar4;
                    puVar7[1] = uVar12;
                    uVar14 = piVar10[4];
                    sVar5 = piVar10[3] - uVar4;
                    pcVar9 = *(code **)(*piVar10 + 8);
                    uVar1 = uVar14 - uVar12;
                    if (0x1f < sVar5) {
                      sVar5 = 0x20;
                    }
                    if (0x1f < uVar1) {
                      uVar1 = 0x20;
                    }
                    puVar6 = puVar7 + 4;
                    puVar7[2] = 0;
                    puVar7[3] = 0;
                    if (pcVar9 == FUN_00b6d408) {
                      if (uVar14 != uVar12) {
                        uVar4 = 0;
                        do {
                          uVar4 = uVar4 + 1;
                          pvVar2 = memset(puVar6,0,sVar5);
                          puVar6 = (uint *)((int)pvVar2 + 0x20);
                        } while (uVar4 < uVar1);
                        uVar4 = *puVar7;
                        uVar3 = puVar7[1];
                      }
                    }
                    else {
                      (*pcVar9)(piVar10,puVar6,uVar4,uVar12,sVar5,uVar1,0x20);
                      uVar4 = *puVar7;
                      uVar3 = puVar7[1];
                    }
                    puVar7[2] = (uint)puVar13;
                    uVar1 = puVar13[3];
                    puVar7[3] = uVar1;
                    *(uint **)(uVar1 + 8) = puVar7;
                    puVar13[3] = (uint)puVar7;
                    piVar10[2] = (int)puVar7;
                  }
                  goto LAB_00b73a68;
                }
                puVar13 = puVar7;
              }
              puVar7 = (uint *)FUN_00b7172c(piVar10,uVar4,uVar12);
              puVar13[3] = (uint)puVar7;
              puVar7[2] = (uint)puVar13;
              uVar4 = *puVar7;
              *(ulonglong *)(piVar10 + 1) = CONCAT44(puVar7,puVar7);
              uVar3 = puVar7[1];
LAB_00b73a68:
              pbVar8 = (byte *)((int)puVar7 + ((uVar17 + 0x10) - uVar4) + (uVar19 - uVar3) * 0x20);
            }
          }
          uVar17 = uVar17 + 1;
          if (*pbVar8 < uVar11) {
            *pbVar8 = (byte)uVar11;
          }
        } while (uVar17 < uVar18);
      }
      fVar15 = fVar15 + 1.0;
      fVar22 = fVar22 + fVar25;
      fVar20 = fVar20 + fVar16;
    } while (fVar15 < fVar24);
  }
  return;
}

