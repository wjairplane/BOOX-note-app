
void FUN_00b6eb78(int param_1)

{
  ulonglong uVar1;
  ulonglong uVar2;
  byte bVar3;
  undefined1 auVar4 [16];
  undefined1 auVar5 [16];
  undefined1 auVar6 [16];
  undefined1 auVar7 [16];
  uint uVar8;
  uint uVar9;
  uint uVar10;
  uint uVar11;
  undefined1 *puVar12;
  undefined8 *puVar13;
  ushort uVar14;
  byte *pbVar15;
  uint uVar16;
  ulonglong *puVar17;
  int *piVar18;
  uint uVar19;
  int iVar20;
  int *piVar21;
  int *piVar22;
  int iVar23;
  int iVar24;
  byte *pbVar25;
  uint uVar26;
  undefined8 *puVar27;
  undefined8 *puVar28;
  uint uVar29;
  uint uVar30;
  int iVar31;
  undefined1 *puVar32;
  undefined8 *puVar33;
  uint uVar34;
  uint *puVar35;
  undefined1 *puVar36;
  undefined1 (*pauVar37) [16];
  ushort *puVar38;
  byte *pbVar39;
  uint uVar40;
  uint uVar41;
  int iVar42;
  uint uVar43;
  undefined1 *puVar44;
  int iVar45;
  uint uVar46;
  int iVar47;
  undefined1 (*pauVar48) [16];
  uint uVar49;
  undefined8 *puVar50;
  undefined8 uVar51;
  ulonglong uVar52;
  undefined8 uVar53;
  undefined1 auVar54 [16];
  ulonglong uVar55;
  undefined1 auVar56 [16];
  ulonglong uVar57;
  undefined8 unaff_d8;
  undefined1 auVar58 [16];
  ulonglong uVar59;
  undefined1 auVar60 [16];
  undefined1 auVar61 [16];
  undefined1 auVar62 [16];
  undefined8 uVar63;
  ulonglong uVar64;
  undefined8 uVar65;
  ulonglong uVar66;
  ulonglong uVar67;
  ulonglong uVar68;
  ulonglong uVar69;
  ulonglong uVar70;
  ulonglong uVar71;
  undefined1 auVar72 [16];
  ulonglong uVar73;
  ulonglong uVar74;
  undefined8 uVar75;
  undefined8 uVar76;
  undefined8 uVar77;
  ulonglong uVar78;
  undefined1 auVar79 [16];
  undefined1 auVar80 [16];
  undefined1 auVar81 [16];
  ulonglong uVar82;
  undefined8 uVar83;
  undefined8 uVar84;
  ulonglong uVar85;
  ulonglong uVar86;
  undefined1 auVar87 [16];
  undefined1 auVar88 [16];
  undefined1 auVar89 [16];
  undefined8 uVar90;
  undefined8 uVar91;
  ulonglong uVar92;
  undefined8 uVar93;
  ulonglong uVar94;
  undefined1 auVar95 [16];
  undefined1 auVar96 [16];
  undefined1 auVar97 [16];
  undefined1 auVar98 [16];
  ulonglong uVar99;
  ulonglong uVar100;
  undefined8 uVar101;
  undefined8 uVar102;
  undefined1 auVar103 [16];
  undefined1 auVar104 [16];
  undefined1 auVar105 [16];
  undefined8 uVar106;
  undefined1 auVar107 [16];
  undefined1 auVar108 [16];
  undefined1 auVar109 [16];
  ulonglong uVar110;
  undefined8 uVar111;
  ulonglong uVar112;
  undefined1 auVar113 [16];
  undefined1 auVar114 [16];
  undefined1 auVar115 [16];
  undefined1 auVar116 [16];
  undefined1 auVar117 [16];
  ulonglong uVar118;
  uint *local_1d0;
  undefined8 uStack_1c8;
  undefined8 local_1b8;
  uint local_1b0;
  undefined8 local_1a8;
  int *local_1a0;
  int local_130;
  uint local_c0;
  
  uVar49 = *(uint *)(param_1 + 0x44);
  uVar40 = uVar49 >> 0x18;
  uVar29 = (uVar49 << 0x10) >> 0x18;
  uVar43 = (uVar49 << 8) >> 0x18;
  uVar34 = uVar49 & 0xff;
  iVar23 = *(int *)(param_1 + 0xc);
  uVar19 = uVar40;
  if (uVar40 == uVar43 && uVar40 == uVar29) {
    uVar19 = 1;
  }
  uVar8 = *(uint *)(param_1 + 0x2c);
  if (uVar40 != uVar43 || uVar40 != uVar29) {
    uVar19 = 0;
  }
  if (uVar40 == uVar34) {
    uVar19 = uVar19 & 1;
  }
  else {
    uVar19 = 0;
  }
  iVar20 = *(int *)(iVar23 + 0x74);
  uVar30 = *(uint *)(iVar23 + 0x84);
  piVar21 = *(int **)(uVar8 + 4);
  if (uVar19 == 0) {
    if (*(int *)(iVar23 + 0x80) == 0x10) {
      if (piVar21 != (int *)0x0) {
        uVar19 = uVar8;
        do {
          iVar23 = *piVar21;
          piVar22 = piVar21 + 4;
          iVar24 = piVar21[1];
          pbVar15 = (byte *)(*(int *)(uVar8 + 0xc) - iVar23);
          uVar10 = *(int *)(uVar8 + 0x10) - iVar24;
          if (&DAT_0000001f < pbVar15) {
            pbVar15 = &DAT_00000020;
          }
          if (0x1f < uVar10) {
            uVar10 = 0x20;
          }
          iVar31 = iVar20 + (iVar24 * (uVar30 >> 1) + iVar23) * 2;
          if ((*(int *)(uVar8 + 0x10) != iVar24) && (*(int *)(uVar8 + 0xc) != iVar23)) {
            iVar23 = (iVar23 + -0x10) - (int)piVar21;
            uVar9 = 0;
            do {
              puVar38 = (ushort *)(iVar31 + -2);
              pbVar39 = (byte *)((int)piVar22 + -1);
              bVar3 = (&DAT_011dd648)[iVar24 + uVar9 & 0xff];
              if (0xffffff < uVar49) {
                uVar19 = 0;
              }
              if (0xffffff >= uVar49) {
                uVar19 = 1;
              }
              do {
                pbVar25 = pbVar39 + iVar23 + 1;
                puVar38 = puVar38 + 1;
                uVar14 = *puVar38;
                pbVar39 = pbVar39 + 1;
                uVar11 = uVar14 & 0x1f;
                uVar16 = (uint)uVar14 << 0x15;
                uVar46 = (uint)*pbVar39 &
                         ~(~((uint)(byte)(&DAT_011dd648)[(uint)bVar3 + ((uint)pbVar25 & 0xff)] <<
                            0x1c) >> 0x1c);
                DataMemoryBarrier(0xb);
                uVar11 = uVar11 >> 2 | uVar11 << 3;
                uVar16 = uVar16 >> 0x1e | (uVar16 >> 0x1a) << 2;
                uVar41 = uVar11 | ((uint)(uVar14 >> 0xd) | (uint)(uVar14 >> 0xb) << 3) << 0x10 |
                         uVar16 << 8;
                if (((DAT_013aeb60 & 1) == 0) &&
                   (iVar47 = __cxa_guard_acquire(&DAT_013aeb60), iVar47 != 0)) {
                  DAT_013aeb64 = qEnvironmentVariableIsEmpty("SHADING_NORMAL_BLEND");
                  __cxa_guard_release(&DAT_013aeb60);
                }
                uVar14 = (ushort)(uVar41 >> 8);
                if (DAT_013aeb64 != '\0') {
                  iVar47 = uVar46 * ((uVar11 * 0x1d + ((uVar41 << 8) >> 0x18) * 0x4c + uVar16 * 0x96
                                     ) / 0xff);
                  uVar46 = iVar47 + (iVar47 + 0x101U >> 8) >> 8;
                }
                uVar26 = uVar19;
                if (uVar46 == 0) {
                  uVar26 = uVar19 | 1;
                }
                if (uVar26 == 0) {
                  iVar47 = 0xff - (uVar46 * uVar40) / 0xff;
                  iVar45 = uVar11 * (iVar47 + (uVar46 * uVar34) / 0xff);
                  iVar42 = ((uVar41 << 8) >> 0x18) * (iVar47 + (uVar46 * uVar43) / 0xff);
                  iVar47 = uVar16 * (iVar47 + (uVar46 * uVar29) / 0xff);
                  uVar41 = iVar47 + (iVar47 + 0x101U >> 8) & 0xffffff00 |
                           iVar45 + (iVar45 + 0x101U >> 8) >> 8 |
                           (iVar42 + (iVar42 + 0x101U >> 8) >> 8) << 0x10;
                  uVar14 = (ushort)(uVar41 >> 8);
                }
                *puVar38 = (ushort)(uVar41 >> 5) & 0x7e0 | (ushort)((uVar41 << 0x18) >> 0x1b) |
                           uVar14 & 0xf800;
              } while (pbVar39 + (1 - (int)piVar22) < pbVar15);
              iVar31 = iVar31 + (uVar30 >> 1) * 2;
              uVar9 = uVar9 + 1;
              iVar23 = iVar23 + -0x20;
              piVar22 = piVar22 + 8;
            } while (uVar9 < uVar10);
          }
          piVar21 = (int *)piVar21[2];
        } while (piVar21 != (int *)0x0);
        return;
      }
    }
    else {
      uVar30 = uVar30 >> 2;
      if (*(char *)(iVar23 + 0x6d) == '\0') {
        if (piVar21 != (int *)0x0) {
          do {
            iVar23 = *piVar21;
            piVar22 = piVar21 + 4;
            iVar24 = piVar21[1];
            puVar44 = (undefined1 *)(*(int *)(uVar8 + 0xc) - iVar23);
            uVar40 = *(int *)(uVar8 + 0x10) - iVar24;
            if ((undefined1 *)0x1f < puVar44) {
              puVar44 = (undefined1 *)0x20;
            }
            if (0x1f < uVar40) {
              uVar40 = 0x20;
            }
            iVar31 = iVar20 + (uVar30 * iVar24 + iVar23) * 4;
            if ((*(int *)(uVar8 + 0x10) != iVar24) && (*(int *)(uVar8 + 0xc) != iVar23)) {
              uVar19 = 0;
              do {
                puVar35 = (uint *)(iVar31 + -4);
                puVar36 = (undefined1 *)((int)piVar22 + -1);
                do {
                  puVar35 = puVar35 + 1;
                  uVar34 = *puVar35;
                  uVar29 = (uint)(byte)puVar36[1];
                  DataMemoryBarrier(0xb);
                  if (((DAT_013aeb60 & 1) == 0) &&
                     (iVar23 = __cxa_guard_acquire(&DAT_013aeb60), iVar23 != 0)) {
                    DAT_013aeb64 = qEnvironmentVariableIsEmpty("SHADING_NORMAL_BLEND");
                    __cxa_guard_release(&DAT_013aeb60);
                  }
                  if (DAT_013aeb64 != '\0') {
                    if (uVar34 >> 0x18 != 0) {
                      iVar23 = uVar29 * (((uVar34 & 0xff) * 0x1d +
                                         ((uVar34 << 8) >> 0x18) * 0x4c +
                                         ((uVar34 << 0x10) >> 0x18) * 0x96) / (uVar34 >> 0x18));
                      uVar29 = iVar23 + (iVar23 + 0x101U >> 8) >> 8;
                    }
                  }
                  if (uVar29 == 0 || uVar49 < 0x1000000) {
                    *puVar35 = uVar34;
                  }
                  else {
                    uVar46 = (uVar34 << 0x10) >> 0x18;
                    uVar43 = ((uVar49 >> 0x18) * uVar29) / 0xff;
                    uVar9 = (uVar34 << 8) >> 0x18;
                    uVar10 = uVar34 >> 0x18;
                    iVar23 = 0xff - uVar43;
                    iVar47 = ((uVar46 - uVar10) + 0xff) *
                             ((((uVar49 << 0x10) >> 0x18) * uVar29) / 0xff) + iVar23 * uVar46;
                    iVar24 = (((uVar34 & 0xff) + 0xff) - uVar10) *
                             ((uVar29 * (uVar49 & 0xff)) / 0xff) + iVar23 * (uVar34 & 0xff);
                    iVar23 = ((uVar9 - uVar10) + 0xff) * ((((uVar49 << 8) >> 0x18) * uVar29) / 0xff)
                             + iVar23 * uVar9;
                    *puVar35 = iVar47 + (iVar47 + 0x101U >> 8) & 0xffffff00 |
                               iVar24 + (iVar24 + 0x101U >> 8) >> 8 |
                               ((uVar43 + uVar10) -
                               (uVar10 * uVar43 + (uVar10 * uVar43 + 0x101 >> 8) >> 8)) * 0x1000000
                               | (iVar23 + (iVar23 + 0x101U >> 8) >> 8) << 0x10;
                  }
                  puVar32 = puVar36 + (2 - (int)piVar22);
                  puVar36 = puVar36 + 1;
                } while (puVar32 < puVar44);
                piVar22 = piVar22 + 8;
                iVar31 = iVar31 + uVar30 * 4;
                uVar19 = uVar19 + 1;
              } while (uVar19 < uVar40);
            }
            piVar21 = (int *)piVar21[2];
          } while (piVar21 != (int *)0x0);
          return;
        }
      }
      else if (piVar21 != (int *)0x0) {
        do {
          iVar24 = *piVar21;
          piVar22 = piVar21 + 4;
          iVar23 = piVar21[1];
          pbVar15 = (byte *)(*(int *)(uVar8 + 0xc) - iVar24);
          uVar40 = *(int *)(uVar8 + 0x10) - iVar23;
          if (&DAT_0000001f < pbVar15) {
            pbVar15 = &DAT_00000020;
          }
          if (0x1f < uVar40) {
            uVar40 = 0x20;
          }
          local_130 = iVar20 + (uVar30 * iVar23 + iVar24) * 4;
          if ((*(int *)(uVar8 + 0x10) != iVar23) && (*(int *)(uVar8 + 0xc) != iVar24)) {
            iVar24 = (iVar24 + -0x10) - (int)piVar21;
            uVar19 = 0;
            do {
              pbVar39 = (byte *)((int)piVar22 + -1);
              bVar3 = (&DAT_011dd648)[uVar19 + iVar23 & 0xff];
              local_1d0 = (uint *)(local_130 + -4);
              do {
                while( true ) {
                  local_1d0 = local_1d0 + 1;
                  uVar34 = *local_1d0;
                  pbVar25 = pbVar39 + iVar24 + 1;
                  pbVar39 = pbVar39 + 1;
                  uVar29 = (uint)*pbVar39 &
                           ~(~((uint)(byte)(&DAT_011dd648)[(uint)bVar3 + ((uint)pbVar25 & 0xff)] <<
                              0x1c) >> 0x1c);
                  DataMemoryBarrier(0xb);
                  if (((DAT_013aeb60 & 1) == 0) &&
                     (iVar31 = __cxa_guard_acquire(&DAT_013aeb60), iVar31 != 0)) {
                    DAT_013aeb64 = qEnvironmentVariableIsEmpty("SHADING_NORMAL_BLEND");
                    __cxa_guard_release(&DAT_013aeb60);
                  }
                  if (DAT_013aeb64 != '\0') {
                    if (uVar34 >> 0x18 != 0) {
                      iVar31 = uVar29 * (((uVar34 & 0xff) * 0x1d +
                                         ((uVar34 << 8) >> 0x18) * 0x4c +
                                         ((uVar34 << 0x10) >> 0x18) * 0x96) / (uVar34 >> 0x18));
                      uVar29 = iVar31 + (iVar31 + 0x101U >> 8) >> 8;
                    }
                  }
                  if (uVar29 != 0 && 0xffffff < uVar49) break;
                  *local_1d0 = uVar34;
                  if (pbVar15 <= pbVar39 + (1 - (int)piVar22)) goto LAB_00b6efd4;
                }
                uVar43 = ((uVar49 >> 0x18) * uVar29) / 0xff;
                uVar46 = (uVar34 << 0x10) >> 0x18;
                uVar9 = (uVar34 << 8) >> 0x18;
                uVar10 = uVar34 >> 0x18;
                iVar31 = 0xff - uVar43;
                iVar45 = ((uVar46 - uVar10) + 0xff) * ((((uVar49 << 0x10) >> 0x18) * uVar29) / 0xff)
                         + iVar31 * uVar46;
                iVar47 = (((uVar34 & 0xff) + 0xff) - uVar10) * ((uVar29 * (uVar49 & 0xff)) / 0xff) +
                         iVar31 * (uVar34 & 0xff);
                iVar31 = ((uVar9 - uVar10) + 0xff) * ((((uVar49 << 8) >> 0x18) * uVar29) / 0xff) +
                         iVar31 * uVar9;
                *local_1d0 = iVar45 + (iVar45 + 0x101U >> 8) & 0xffffff00 |
                             iVar47 + (iVar47 + 0x101U >> 8) >> 8 |
                             ((uVar43 + uVar10) -
                             (uVar10 * uVar43 + (uVar10 * uVar43 + 0x101 >> 8) >> 8)) * 0x1000000 |
                             (iVar31 + (iVar31 + 0x101U >> 8) >> 8) << 0x10;
              } while (pbVar39 + (1 - (int)piVar22) < pbVar15);
LAB_00b6efd4:
              piVar22 = piVar22 + 8;
              uVar19 = uVar19 + 1;
              iVar24 = iVar24 + -0x20;
              local_130 = local_130 + uVar30 * 4;
            } while (uVar19 < uVar40);
          }
          piVar21 = (int *)piVar21[2];
        } while (piVar21 != (int *)0x0);
      }
    }
  }
  else if (*(int *)(iVar23 + 0x80) == 0x10) {
    if (piVar21 != (int *)0x0) {
      iVar24 = *(int *)(uVar8 + 0xc);
      iVar23 = *(int *)(uVar8 + 0x10);
      do {
        iVar31 = *piVar21;
        iVar47 = piVar21[1];
        pbVar15 = (byte *)(iVar24 - iVar31);
        uVar40 = iVar23 - iVar47;
        if (&DAT_0000001f < pbVar15) {
          pbVar15 = &DAT_00000020;
        }
        if (0x1f < uVar40) {
          uVar40 = 0x20;
        }
        local_1b0 = iVar20 + (iVar47 * (uVar30 >> 1) + iVar31) * 2;
        piVar22 = piVar21 + 4;
        if ((iVar23 != iVar47) && (iVar24 != iVar31)) {
          iVar31 = (iVar31 + -0x10) - (int)piVar21;
          uVar19 = 0;
          do {
            pbVar39 = (byte *)((int)piVar22 + -1);
            bVar3 = (&DAT_011dd648)[iVar47 + uVar19 & 0xff];
            puVar38 = (ushort *)(local_1b0 + -2);
            do {
              pbVar25 = pbVar39 + iVar31 + 1;
              puVar38 = puVar38 + 1;
              uVar14 = *puVar38;
              pbVar39 = pbVar39 + 1;
              uVar10 = ~(~((uint)(byte)(&DAT_011dd648)[(uint)bVar3 + ((uint)pbVar25 & 0xff)] << 0x1c
                          ) >> 0x1c) & (uint)*pbVar39;
              uVar46 = (uint)uVar14 << 0x15;
              uVar8 = uVar14 & 0x1f;
              uVar9 = uVar8 << 3 | uVar8 >> 2;
              uVar8 = uVar9;
              if (uVar10 != 0) {
                uVar8 = (uint)(uVar49 < 0x1000000);
              }
              if (uVar10 == 0) {
                uVar8 = 1;
              }
              uVar46 = uVar9 | ((uint)(uVar14 >> 0xb) << 3 | (uint)(uVar14 >> 0xd)) << 0x10 |
                       ((uVar46 >> 0x1a) << 2 | uVar46 >> 0x1e) << 8;
              if (uVar8 == 0) {
                uVar8 = ((uVar46 << 0x10) >> 0x18) + (uVar10 * uVar29) / 0xff;
                if (0xfe < uVar8) {
                  uVar8 = 0xff;
                }
                uVar46 = ((uVar46 << 8) >> 0x18) + (uVar10 * uVar43) / 0xff;
                if (0xfe < uVar46) {
                  uVar46 = 0xff;
                }
                uVar9 = uVar9 + (uVar10 * uVar34) / 0xff;
                uVar46 = uVar46 << 0x10 | uVar8 << 8;
                if (uVar9 < 0x100) {
                  uVar46 = uVar46 | uVar9;
                }
                else {
                  uVar46 = uVar46 | 0xff;
                }
              }
              *puVar38 = (ushort)(uVar46 >> 5) & 0x7e0 | (ushort)(uVar46 >> 8) & 0xf800 |
                         (ushort)((uVar46 << 0x18) >> 0x1b);
            } while (pbVar39 + (1 - (int)piVar22) < pbVar15);
            local_1b0 = local_1b0 + (uVar30 >> 1) * 2;
            uVar19 = uVar19 + 1;
            iVar31 = iVar31 + -0x20;
            piVar22 = piVar22 + 8;
          } while (uVar19 < uVar40);
        }
        piVar21 = (int *)piVar21[2];
      } while (piVar21 != (int *)0x0);
    }
  }
  else {
    uVar30 = uVar30 >> 2;
    if (*(char *)(iVar23 + 0x6d) == '\0') {
      if (piVar21 != (int *)0x0) {
        piVar22 = piVar21;
        if (0xffffff < uVar49) {
          piVar22 = (int *)0x0;
        }
        auVar7._12_4_ = uVar40;
        auVar7._8_4_ = uVar40;
        if (0xffffff >= uVar49) {
          piVar22 = (int *)&DAT_00000001;
        }
        iVar23 = -(int)piVar22;
        auVar58._8_8_ = unaff_d8;
        auVar58._0_8_ = 0x8080808180808081;
        do {
          iVar24 = piVar21[1];
          iVar31 = *piVar21;
          puVar36 = (undefined1 *)(*(int *)(uVar8 + 0xc) - iVar31);
          uVar19 = *(int *)(uVar8 + 0x10) - iVar24;
          puVar50 = (undefined8 *)(iVar20 + (uVar30 * iVar24 + iVar31) * 4);
          puVar44 = puVar36;
          if (&DAT_0000001f < puVar36) {
            puVar44 = (undefined1 *)0x20;
          }
          if (0x1f < uVar19) {
            uVar19 = 0x20;
          }
          pauVar48 = (undefined1 (*) [16])(piVar21 + 4);
          if ((*(int *)(uVar8 + 0x10) != iVar24) && (*(int *)(uVar8 + 0xc) != iVar31)) {
            auVar5._12_4_ = uVar43;
            auVar5._8_4_ = uVar43;
            auVar6._12_4_ = uVar29;
            auVar6._8_4_ = uVar29;
            uVar1 = CONCAT44(uVar49,uVar49) & 0xff000000ff;
            local_c0 = 0;
            do {
              uVar75 = DAT_00b6fa98;
              uVar63 = DAT_00b6fa90;
              if ((puVar36 < (undefined1 *)0x8) ||
                 (puVar50 < *pauVar48 + (int)puVar44 &&
                  pauVar48 < (undefined1 (*) [16])((int)puVar50 + (int)puVar44 * 4))) {
                puVar35 = (uint *)((int)puVar50 + -4);
                puVar32 = pauVar48[-1] + 0xf;
                do {
                  uVar10 = (uint)(byte)puVar32[1];
                  puVar12 = puVar32 + (2 - (int)pauVar48);
                  puVar32 = puVar32 + 1;
                  piVar18 = piVar22;
                  if (uVar10 == 0) {
                    piVar18 = (int *)((uint)piVar22 | 1);
                  }
                  puVar35 = puVar35 + 1;
                  uVar9 = *puVar35;
                  if (piVar18 == (int *)0x0) {
                    uVar46 = ((uVar9 << 8) >> 0x18) + (uVar10 * uVar43) / 0xff;
                    if (0xfe < uVar46) {
                      uVar46 = 0xff;
                    }
                    uVar11 = (uVar9 >> 0x18) + (uVar10 * uVar40) / 0xff;
                    if (0xfe < uVar11) {
                      uVar11 = 0xff;
                    }
                    uVar46 = uVar11 << 0x18 | uVar46 << 0x10;
                    uVar11 = (uVar9 & 0xff) + (uVar10 * uVar34) / 0xff;
                    if (uVar11 < 0x100) {
                      uVar46 = uVar46 | uVar11;
                    }
                    else {
                      uVar46 = uVar46 | 0xff;
                    }
                    uVar10 = ((uVar9 << 0x10) >> 0x18) + (uVar10 * uVar29) / 0xff;
                    if (0xfe < uVar10) {
                      uVar10 = 0xff;
                    }
                    *puVar35 = uVar46 | uVar10 << 8;
                  }
                } while (puVar12 < puVar44);
              }
              else if (puVar36 < (undefined1 *)0x10) {
                uVar10 = 0;
                puVar32 = puVar44;
LAB_00b6ff28:
                uVar63 = CONCAT44(uVar40,uVar40);
                iVar24 = ((uint)puVar32 & 0xfffffff8) + uVar10;
                uVar75 = CONCAT44(uVar43,uVar43);
                uVar71 = SIMDExpandImmediate(0,0,0xff);
                uVar76 = CONCAT44(uVar29,uVar29);
                uVar69 = CONCAT44(uVar49,uVar49) & 0xff000000ff;
                uVar2 = CONCAT44(iVar23,iVar23);
                puVar17 = (ulonglong *)((int)puVar50 + uVar10 * 4);
                auVar89 = VectorCopyLong(*(undefined8 *)(*pauVar48 + uVar10),1,1);
                auVar107 = VectorCopyLong(auVar89._0_8_,2,1);
                auVar89 = VectorCopyLong(auVar89._8_8_,2,1);
                uVar91 = auVar107._8_8_;
                uVar51 = VectorMultiply(uVar63,uVar91,4);
                uVar53 = auVar89._0_8_;
                uVar111 = VectorMultiply(uVar75,uVar53,4);
                auVar113 = VectorMultiply(uVar51,auVar58._0_8_,4,1);
                uVar51 = VectorMultiply(uVar63,uVar53,4);
                auVar61 = VectorMultiply(uVar111,auVar58._0_8_,4,1);
                auVar60 = VectorMultiply(uVar51,auVar58._0_8_,4,1);
                uVar51 = VectorMultiply(uVar75,uVar91,4);
                auVar80 = VectorMultiply(uVar51,auVar58._0_8_,4,1);
                VectorTranspose(auVar61._8_8_,4);
                uVar51 = auVar89._8_8_;
                uVar101 = VectorMultiply(uVar75,uVar51,4);
                VectorTranspose(auVar60._8_8_,4);
                uVar111 = VectorMultiply(uVar63,uVar51,4);
                VectorTranspose(auVar80._8_8_,4);
                auVar54 = VectorMultiply(uVar101,auVar58._0_8_,4,1);
                auVar87 = VectorMultiply(uVar111,auVar58._0_8_,4,1);
                VectorTranspose(auVar113._8_8_,4);
                uVar111 = VectorMultiply(uVar69,uVar91,4);
                VectorTranspose(auVar54._8_8_,4);
                auVar56 = VectorMultiply(uVar111,auVar58._0_8_,4,1);
                VectorTranspose(auVar87._8_8_,4);
                uVar111 = VectorMultiply(uVar69,uVar51,4);
                uVar77 = auVar107._0_8_;
                uVar75 = VectorMultiply(uVar75,uVar77,4);
                auVar89 = VectorMultiply(uVar111,auVar58._0_8_,4,1);
                uVar63 = VectorMultiply(uVar63,uVar77,4);
                VectorTranspose(auVar89._8_8_,4);
                auVar107 = VectorMultiply(uVar75,auVar58._0_8_,4,1);
                uVar75 = VectorShiftRight(auVar60._8_8_,7);
                VectorTranspose(auVar56._8_8_,4);
                uVar118 = *puVar17;
                auVar60 = VectorMultiply(uVar63,auVar58._0_8_,4,1);
                uVar57 = puVar17[1];
                uVar112 = puVar17[2];
                VectorTranspose(auVar60._8_8_,4);
                uVar64 = VectorShiftRight(uVar57,0x10);
                uVar63 = VectorShiftRight(auVar80._8_8_,7);
                uVar110 = puVar17[3];
                uVar111 = VectorAdd(uVar63,uVar64 & uVar71,4);
                uVar64 = VectorShiftRight(uVar112,0x10);
                uVar63 = VectorShiftRight(auVar61._8_8_,7);
                uVar83 = VectorShiftRight(auVar54._8_8_,7);
                uVar65 = VectorAdd(uVar63,uVar64 & uVar71,4);
                uVar64 = VectorShiftRight(uVar110,0x10);
                uVar102 = VectorMultiply(uVar76,uVar91,4);
                uVar63 = VectorMultiply(uVar69,uVar77,4);
                uVar101 = VectorMultiply(uVar69,uVar53,4);
                uVar84 = VectorAdd(uVar83,uVar64 & uVar71,4);
                uVar93 = VectorMultiply(uVar76,uVar53,4);
                uVar83 = VectorMultiply(uVar76,uVar51,4);
                uVar106 = VectorMultiply(uVar76,uVar77,4);
                uVar68 = VectorCompareEqual(uVar77,0,4);
                VectorTranspose(auVar107._8_8_,4);
                uVar69 = VectorShiftRight(uVar118,0x10);
                uVar76 = VectorShiftRight(auVar107._8_8_,7);
                uVar90 = VectorShiftRight(auVar113._8_8_,7);
                uVar77 = VectorAdd(uVar76,uVar69 & uVar71,4);
                uVar76 = VectorShiftRight(uVar57,0x18);
                uVar59 = VectorCompareEqual(uVar91,0,4);
                uVar91 = VectorAdd(uVar90,uVar76,4);
                auVar113 = VectorMultiply(uVar102,auVar58._0_8_,4,1);
                uVar76 = VectorMin(uVar65,uVar71,4,1);
                uVar65 = VectorShiftRight(uVar112,0x18);
                auVar61 = VectorMultiply(uVar101,auVar58._0_8_,4,1);
                uVar75 = VectorAdd(uVar75,uVar65,4);
                uVar66 = VectorShiftLeft(uVar76,0x10,0x20,0);
                uVar75 = VectorMin(uVar75,uVar71,4,1);
                uVar52 = VectorShiftLeft(uVar75,0x18,0x20,0);
                uVar75 = VectorShiftRight(auVar87._8_8_,7);
                auVar87 = VectorMultiply(uVar93,auVar58._0_8_,4,1);
                VectorTranspose(auVar61._8_8_,4);
                uVar76 = VectorMin(uVar84,uVar71,4,1);
                VectorTranspose(auVar87._8_8_,4);
                uVar101 = VectorShiftRight(uVar110,0x18);
                uVar85 = VectorShiftLeft(uVar76,0x10,0x20,0);
                uVar75 = VectorAdd(uVar75,uVar101,4);
                auVar80 = VectorMultiply(uVar83,auVar58._0_8_,4,1);
                uVar75 = VectorMin(uVar75,uVar71,4,1);
                uVar64 = VectorShiftLeft(uVar75,0x18,0x20,0);
                VectorTranspose(auVar113._8_8_,4);
                auVar54 = VectorMultiply(uVar63,auVar58._0_8_,4,1);
                VectorTranspose(auVar80._8_8_,4);
                uVar63 = VectorShiftRight(auVar60._8_8_,7);
                uVar65 = VectorShiftRight(auVar80._8_8_,7);
                uVar76 = VectorShiftRight(uVar118,0x18);
                uVar75 = VectorShiftRight(auVar113._8_8_,7);
                uVar63 = VectorAdd(uVar63,uVar76,4);
                uVar101 = VectorShiftRight(auVar87._8_8_,7);
                VectorTranspose(auVar54._8_8_,4);
                auVar87 = VectorMultiply(uVar106,auVar58._0_8_,4,1);
                uVar76 = VectorShiftRight(auVar56._8_8_,7);
                uVar69 = VectorShiftRight(uVar57,8);
                VectorTranspose(auVar87._8_8_,4);
                uVar83 = VectorShiftRight(auVar87._8_8_,7);
                uVar84 = VectorAdd(uVar75,uVar69 & uVar71,4);
                uVar69 = VectorShiftRight(uVar112,8);
                uVar75 = VectorMin(uVar111,uVar71,4,1);
                uVar91 = VectorMin(uVar91,uVar71,4,1);
                uVar111 = VectorAdd(uVar101,uVar69 & uVar71,4);
                uVar69 = VectorShiftRight(uVar110,8);
                uVar55 = VectorShiftLeft(uVar75,0x10,0x20,0);
                uVar92 = VectorShiftLeft(uVar91,0x18,0x20,0);
                uVar101 = VectorAdd(uVar65,uVar69 & uVar71,4);
                uVar69 = VectorShiftRight(uVar118,8);
                uVar75 = VectorMin(uVar84,uVar71,4,1);
                uVar91 = VectorAdd(uVar83,uVar69 & uVar71,4);
                uVar99 = VectorShiftLeft(uVar75,8,0x20,0);
                uVar75 = VectorAdd(uVar76,uVar57 & uVar71,4);
                uVar76 = VectorShiftRight(auVar61._8_8_,7);
                uVar94 = VectorMin(uVar75,uVar71,4,1);
                uVar75 = VectorShiftRight(auVar89._8_8_,7);
                uVar65 = VectorMin(uVar77,uVar71,4,1);
                uVar83 = VectorAdd(uVar76,uVar112 & uVar71,4);
                uVar63 = VectorMin(uVar63,uVar71,4,1);
                uVar75 = VectorAdd(uVar75,uVar110 & uVar71,4);
                uVar77 = VectorShiftRight(auVar54._8_8_,7);
                uVar78 = VectorShiftLeft(uVar65,0x10,0x20,0);
                uVar69 = VectorShiftLeft(uVar63,0x18,0x20,0);
                uVar63 = VectorMin(uVar111,uVar71,4,1);
                uVar76 = VectorMin(uVar101,uVar71,4,1);
                uVar100 = VectorMin(uVar83,uVar71,4,1);
                uVar111 = VectorAdd(uVar77,uVar118 & uVar71,4);
                uVar67 = VectorMin(uVar75,uVar71,4,1);
                uVar70 = VectorShiftLeft(uVar63,8,0x20,0);
                uVar73 = VectorShiftLeft(uVar76,8,0x20,0);
                uVar63 = VectorMin(uVar91,uVar71,4,1);
                uVar86 = VectorMin(uVar111,uVar71,4,1);
                uVar82 = VectorShiftLeft(uVar63,8,0x20,0);
                uVar74 = VectorCompareEqual(uVar53,0,4);
                uVar71 = VectorCompareEqual(uVar51,0,4);
                uVar55 = VectorBitwiseInsertIfTrue
                                   (uVar55 | uVar92 | uVar94 | uVar99,uVar57,uVar59 | uVar2);
                auVar58._8_8_ =
                     VectorBitwiseSelect(uVar68 | uVar2,uVar118,uVar78 | uVar69 | uVar86 | uVar82);
                uVar69 = VectorBitwiseSelect(uVar74 | uVar2,uVar112,
                                             uVar66 | uVar52 | uVar100 | uVar70);
                uVar71 = VectorBitwiseInsertIfTrue
                                   (uVar85 | uVar64 | uVar67 | uVar73,uVar110,uVar71 | uVar2);
                *puVar17 = auVar58._8_8_;
                puVar17[1] = uVar55;
                puVar17[2] = uVar69;
                puVar17[3] = uVar71;
                if (((uint)puVar32 & 7) != 0) {
LAB_00b70294:
                  uVar10 = (uint)(byte)(*pauVar48)[iVar24];
                  iVar31 = iVar24 * 4;
                  piVar18 = piVar22;
                  if (uVar10 == 0) {
                    piVar18 = (int *)((uint)piVar22 | 1);
                  }
                  uVar9 = *(uint *)((int)puVar50 + iVar24 * 4);
                  if (piVar18 == (int *)0x0) {
                    uVar46 = ((uVar9 << 8) >> 0x18) + (uVar10 * uVar43) / 0xff;
                    if (0xfe < uVar46) {
                      uVar46 = 0xff;
                    }
                    uVar11 = (uVar9 >> 0x18) + (uVar10 * uVar40) / 0xff;
                    if (0xfe < uVar11) {
                      uVar11 = 0xff;
                    }
                    uVar46 = uVar11 << 0x18 | uVar46 << 0x10;
                    uVar11 = (uVar9 & 0xff) + (uVar10 * uVar34) / 0xff;
                    if (uVar11 < 0x100) {
                      uVar46 = uVar46 | uVar11;
                    }
                    else {
                      uVar46 = uVar46 | 0xff;
                    }
                    uVar10 = ((uVar9 << 0x10) >> 0x18) + (uVar10 * uVar29) / 0xff;
                    if (0xfe < uVar10) {
                      uVar10 = 0xff;
                    }
                    uVar9 = uVar46 | uVar10 << 8;
                  }
                  *(uint *)((int)puVar50 + iVar31) = uVar9;
                  if ((undefined1 *)(iVar24 + 1) < puVar44) {
                    uVar10 = (uint)(byte)(*pauVar48)[iVar24 + 1];
                    piVar18 = piVar22;
                    if (uVar10 == 0) {
                      piVar18 = (int *)((uint)piVar22 | 1);
                    }
                    uVar9 = *(uint *)((int)puVar50 + iVar31 + 4);
                    if (piVar18 == (int *)0x0) {
                      uVar46 = ((uVar9 << 8) >> 0x18) + (uVar10 * uVar43) / 0xff;
                      if (0xfe < uVar46) {
                        uVar46 = 0xff;
                      }
                      uVar11 = (uVar9 >> 0x18) + (uVar10 * uVar40) / 0xff;
                      if (0xfe < uVar11) {
                        uVar11 = 0xff;
                      }
                      uVar46 = uVar11 << 0x18 | uVar46 << 0x10;
                      uVar11 = (uVar9 & 0xff) + (uVar10 * uVar34) / 0xff;
                      if (uVar11 < 0x100) {
                        uVar46 = uVar46 | uVar11;
                      }
                      else {
                        uVar46 = uVar46 | 0xff;
                      }
                      uVar10 = ((uVar9 << 0x10) >> 0x18) + (uVar10 * uVar29) / 0xff;
                      if (0xfe < uVar10) {
                        uVar10 = 0xff;
                      }
                      uVar9 = uVar46 | uVar10 << 8;
                    }
                    *(uint *)((int)puVar50 + iVar31 + 4) = uVar9;
                    if ((undefined1 *)(iVar24 + 2) < puVar44) {
                      uVar10 = (uint)(byte)(*pauVar48)[iVar24 + 2];
                      piVar18 = piVar22;
                      if (uVar10 == 0) {
                        piVar18 = (int *)((uint)piVar22 | 1);
                      }
                      uVar9 = *(uint *)((int)puVar50 + iVar31 + 8);
                      if (piVar18 == (int *)0x0) {
                        uVar46 = ((uVar9 << 8) >> 0x18) + (uVar10 * uVar43) / 0xff;
                        if (0xfe < uVar46) {
                          uVar46 = 0xff;
                        }
                        uVar11 = (uVar9 >> 0x18) + (uVar10 * uVar40) / 0xff;
                        if (0xfe < uVar11) {
                          uVar11 = 0xff;
                        }
                        uVar46 = uVar11 << 0x18 | uVar46 << 0x10;
                        uVar11 = (uVar9 & 0xff) + (uVar10 * uVar34) / 0xff;
                        if (uVar11 < 0x100) {
                          uVar46 = uVar46 | uVar11;
                        }
                        else {
                          uVar46 = uVar46 | 0xff;
                        }
                        uVar10 = ((uVar9 << 0x10) >> 0x18) + (uVar10 * uVar29) / 0xff;
                        if (0xfe < uVar10) {
                          uVar10 = 0xff;
                        }
                        uVar9 = uVar46 | uVar10 << 8;
                      }
                      *(uint *)((int)puVar50 + iVar31 + 8) = uVar9;
                      if ((undefined1 *)(iVar24 + 3) < puVar44) {
                        uVar10 = (uint)(byte)(*pauVar48)[iVar24 + 3];
                        piVar18 = piVar22;
                        if (uVar10 == 0) {
                          piVar18 = (int *)((uint)piVar22 | 1);
                        }
                        uVar9 = *(uint *)((int)puVar50 + iVar31 + 0xc);
                        if (piVar18 == (int *)0x0) {
                          uVar46 = ((uVar9 << 8) >> 0x18) + (uVar10 * uVar43) / 0xff;
                          if (0xfe < uVar46) {
                            uVar46 = 0xff;
                          }
                          uVar11 = (uVar9 >> 0x18) + (uVar10 * uVar40) / 0xff;
                          if (0xfe < uVar11) {
                            uVar11 = 0xff;
                          }
                          uVar46 = uVar11 << 0x18 | uVar46 << 0x10;
                          uVar11 = (uVar9 & 0xff) + (uVar10 * uVar34) / 0xff;
                          if (uVar11 < 0x100) {
                            uVar46 = uVar46 | uVar11;
                          }
                          else {
                            uVar46 = uVar46 | 0xff;
                          }
                          uVar10 = ((uVar9 << 0x10) >> 0x18) + (uVar10 * uVar29) / 0xff;
                          if (0xfe < uVar10) {
                            uVar10 = 0xff;
                          }
                          uVar9 = uVar46 | uVar10 << 8;
                        }
                        *(uint *)((int)puVar50 + iVar31 + 0xc) = uVar9;
                        if ((undefined1 *)(iVar24 + 4) < puVar44) {
                          uVar10 = (uint)(byte)(*pauVar48)[iVar24 + 4];
                          piVar18 = piVar22;
                          if (uVar10 == 0) {
                            piVar18 = (int *)((uint)piVar22 | 1);
                          }
                          uVar9 = *(uint *)((int)puVar50 + iVar31 + 0x10);
                          if (piVar18 == (int *)0x0) {
                            uVar46 = ((uVar9 << 8) >> 0x18) + (uVar10 * uVar43) / 0xff;
                            if (0xfe < uVar46) {
                              uVar46 = 0xff;
                            }
                            uVar11 = (uVar9 >> 0x18) + (uVar10 * uVar40) / 0xff;
                            if (0xfe < uVar11) {
                              uVar11 = 0xff;
                            }
                            uVar46 = uVar11 << 0x18 | uVar46 << 0x10;
                            uVar11 = (uVar9 & 0xff) + (uVar10 * uVar34) / 0xff;
                            if (uVar11 < 0x100) {
                              uVar46 = uVar46 | uVar11;
                            }
                            else {
                              uVar46 = uVar46 | 0xff;
                            }
                            uVar10 = ((uVar9 << 0x10) >> 0x18) + (uVar10 * uVar29) / 0xff;
                            if (0xfe < uVar10) {
                              uVar10 = 0xff;
                            }
                            uVar9 = uVar46 | uVar10 << 8;
                          }
                          *(uint *)((int)puVar50 + iVar31 + 0x10) = uVar9;
                          if ((undefined1 *)(iVar24 + 5) < puVar44) {
                            uVar10 = (uint)(byte)(*pauVar48)[iVar24 + 5];
                            piVar18 = piVar22;
                            if (uVar10 == 0) {
                              piVar18 = (int *)((uint)piVar22 | 1);
                            }
                            uVar9 = *(uint *)((int)puVar50 + iVar31 + 0x14);
                            if (piVar18 == (int *)0x0) {
                              uVar46 = ((uVar9 << 8) >> 0x18) + (uVar10 * uVar43) / 0xff;
                              if (0xfe < uVar46) {
                                uVar46 = 0xff;
                              }
                              uVar11 = (uVar9 >> 0x18) + (uVar10 * uVar40) / 0xff;
                              if (0xfe < uVar11) {
                                uVar11 = 0xff;
                              }
                              uVar46 = uVar11 << 0x18 | uVar46 << 0x10;
                              uVar11 = (uVar9 & 0xff) + (uVar10 * uVar34) / 0xff;
                              if (uVar11 < 0x100) {
                                uVar46 = uVar46 | uVar11;
                              }
                              else {
                                uVar46 = uVar46 | 0xff;
                              }
                              uVar10 = ((uVar9 << 0x10) >> 0x18) + (uVar10 * uVar29) / 0xff;
                              if (0xfe < uVar10) {
                                uVar10 = 0xff;
                              }
                              uVar9 = uVar46 | uVar10 << 8;
                            }
                            *(uint *)((int)puVar50 + iVar31 + 0x14) = uVar9;
                            if ((undefined1 *)(iVar24 + 6) < puVar44) {
                              uVar10 = (uint)(byte)(*pauVar48)[iVar24 + 6];
                              uVar9 = *(uint *)((int)puVar50 + iVar31 + 0x18);
                              piVar18 = piVar22;
                              if (uVar10 == 0) {
                                piVar18 = (int *)((uint)piVar22 | 1);
                              }
                              if (piVar18 == (int *)0x0) {
                                uVar46 = ((uVar9 << 8) >> 0x18) + (uVar10 * uVar43) / 0xff;
                                if (0xfe < uVar46) {
                                  uVar46 = 0xff;
                                }
                                uVar11 = (uVar9 >> 0x18) + (uVar10 * uVar40) / 0xff;
                                if (0xfe < uVar11) {
                                  uVar11 = 0xff;
                                }
                                uVar11 = uVar11 << 0x18 | uVar46 << 0x10;
                                uVar46 = (uVar9 & 0xff) + (uVar10 * uVar34) / 0xff;
                                if (uVar46 < 0x100) {
                                  uVar11 = uVar11 | uVar46;
                                }
                                else {
                                  uVar11 = uVar11 | 0xff;
                                }
                                uVar10 = ((uVar9 << 0x10) >> 0x18) + (uVar10 * uVar29) / 0xff;
                                if (0xfe < uVar10) {
                                  uVar10 = 0xff;
                                }
                                uVar9 = uVar11 | uVar10 << 8;
                              }
                              *(uint *)((int)puVar50 + iVar31 + 0x18) = uVar9;
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              else {
                auVar89 = SIMDExpandImmediate(0,0,0xff);
                puVar27 = puVar50;
                pauVar37 = pauVar48;
                do {
                  auVar61 = *pauVar37;
                  pauVar37 = pauVar37 + 1;
                  auVar4._4_4_ = iVar23;
                  auVar4._0_4_ = iVar23;
                  auVar4._8_8_ = CONCAT44(iVar23,iVar23);
                  auVar87 = VectorCopyLong(auVar61._0_8_,1,1);
                  auVar61 = VectorCopyLong(auVar61._8_8_,1,1);
                  auVar56 = VectorCopyLong(auVar87._0_8_,2,1);
                  auVar72 = VectorCopyLong(auVar61._0_8_,2,1);
                  auVar62 = VectorCopyLong(auVar61._8_8_,2,1);
                  auVar95 = VectorCompareEqual(auVar72,0,4);
                  auVar79 = VectorCompareEqual(auVar62,0,4);
                  auVar88 = VectorCopyLong(auVar87._8_8_,2,1);
                  auVar5._4_4_ = uVar43;
                  auVar5._0_4_ = uVar43;
                  puVar33 = puVar27 + 4;
                  auVar7._4_4_ = uVar40;
                  auVar7._0_4_ = uVar40;
                  auVar103 = VectorCompareEqual(auVar88,0,4);
                  auVar80 = VectorMultiply(auVar5,auVar56,4);
                  auVar61 = VectorMultiply(auVar7,auVar56,4);
                  auVar87 = VectorMultiply(auVar7,auVar88,4);
                  auVar96 = VectorMultiply(auVar7,auVar62,4);
                  auVar54 = VectorMultiply(auVar7,auVar72,4);
                  VectorMultiply(auVar80._0_8_,uVar63,4,1);
                  auVar81 = VectorMultiply(auVar80._8_8_,uVar75,4,1);
                  puVar13 = puVar27 + 6;
                  auVar113 = VectorMultiply(auVar5,auVar88,4);
                  VectorUnzip(auVar81,4);
                  VectorMultiply(auVar61._0_8_,uVar63,4,1);
                  auVar61 = VectorMultiply(auVar61._8_8_,uVar75,4,1);
                  VectorUnzip(auVar61,4);
                  auVar80 = VectorUnsignedFixedToFloat(auVar61,7);
                  auVar107 = VectorMultiply(auVar5,auVar72,4);
                  auVar104 = VectorMultiply(auVar5,auVar62,4);
                  uVar76 = *puVar13;
                  puVar28 = puVar27 + 7;
                  auVar61 = *(undefined1 (*) [16])(puVar27 + 2);
                  VectorMultiply(auVar113._0_8_,uVar63,4,1);
                  auVar114 = VectorMultiply(auVar113._8_8_,uVar75,4,1);
                  VectorMultiply(auVar87._0_8_,uVar63,4,1);
                  VectorUnzip(auVar114,4);
                  auVar87 = VectorMultiply(auVar87._8_8_,uVar75,4,1);
                  VectorUnzip(auVar87,4);
                  auVar60 = VectorUnsignedFixedToFloat(auVar61,0x10);
                  auVar113 = VectorUnsignedFixedToFloat(auVar87,7);
                  VectorMultiply(auVar107._0_8_,uVar63,4,1);
                  auVar108 = VectorMultiply(auVar107._8_8_,uVar75,4,1);
                  auVar115 = VectorUnsignedFixedToFloat(auVar114,7);
                  VectorUnzip(auVar108,4);
                  VectorMultiply(auVar54._0_8_,uVar63,4,1);
                  auVar87 = VectorMultiply(auVar54._8_8_,uVar75,4,1);
                  auVar6._4_4_ = uVar29;
                  auVar6._0_4_ = uVar29;
                  VectorUnzip(auVar87,4);
                  auVar114._8_8_ = uVar1;
                  auVar114._0_8_ = uVar1;
                  auVar107 = VectorUnsignedFixedToFloat(auVar87,7);
                  auVar116 = VectorAdd(auVar115,auVar60 & auVar89,4);
                  VectorMultiply(auVar104._0_8_,uVar63,4,1);
                  auVar105 = VectorMultiply(auVar104._8_8_,uVar75,4,1);
                  auVar87._8_8_ = uStack_1c8;
                  auVar87._0_8_ = *puVar33;
                  VectorUnzip(auVar105,4);
                  VectorMultiply(auVar96._0_8_,uVar63,4,1);
                  auVar54 = VectorMultiply(auVar96._8_8_,uVar75,4,1);
                  auVar104._4_4_ = iVar23;
                  auVar104._0_4_ = iVar23;
                  auVar104._8_8_ = CONCAT44(iVar23,iVar23);
                  VectorUnzip(auVar54,4);
                  auVar87 = VectorUnsignedFixedToFloat(auVar87,0x10);
                  auVar97 = VectorUnsignedFixedToFloat(auVar54,7);
                  auVar60 = VectorMultiply(auVar114,auVar56,4);
                  auVar98 = VectorMultiply(auVar6,auVar56,4);
                  auVar115 = VectorCompareEqual(auVar56,0,4);
                  auVar54 = VectorUnsignedFixedToFloat(auVar108,7);
                  auVar109 = VectorAdd(auVar54,auVar87 & auVar89,4);
                  auVar96._8_8_ = local_1a8;
                  auVar96._0_8_ = *puVar28;
                  auVar56._8_8_ = local_1b8;
                  auVar56._0_8_ = *puVar13;
                  auVar87 = VectorUnsignedFixedToFloat(auVar96,0x10);
                  auVar54 = VectorUnsignedFixedToFloat(auVar56,0x10);
                  auVar56 = VectorUnsignedFixedToFloat(auVar81,7);
                  auVar96 = VectorUnsignedFixedToFloat(auVar105,7);
                  auVar105 = VectorAdd(auVar56,auVar87 & auVar89,4);
                  auVar108 = VectorAdd(auVar96,auVar54 & auVar89,4);
                  auVar81._8_8_ = local_1a8;
                  auVar81._0_8_ = *puVar28;
                  auVar54 = VectorMultiply(auVar114,auVar88,4);
                  auVar56 = VectorMultiply(auVar114,auVar62,4);
                  auVar88 = VectorMultiply(auVar6,auVar88,4);
                  auVar87 = VectorMultiply(auVar114,auVar72,4);
                  auVar62 = VectorMultiply(auVar6,auVar62,4);
                  auVar114 = VectorMultiply(auVar6,auVar72,4);
                  auVar96 = VectorUnsignedFixedToFloat(auVar81,0x18);
                  auVar81 = VectorMin(auVar105,auVar89,4,1);
                  auVar80 = VectorAdd(auVar80,auVar96,4);
                  auVar81 = VectorShiftLeft(auVar81,0x10,0x20,0);
                  auVar80 = VectorMin(auVar80,auVar89,4,1);
                  auVar72 = VectorMin(auVar116,auVar89,4,1);
                  auVar96 = VectorShiftLeft(auVar80,0x18,0x20,0);
                  auVar116 = VectorShiftLeft(auVar72,0x10,0x20,0);
                  VectorMultiply(auVar60._0_8_,uVar63,4,1);
                  auVar80 = VectorMultiply(auVar60._8_8_,uVar75,4,1);
                  auVar60 = VectorMin(auVar109,auVar89,4,1);
                  VectorUnzip(auVar80,4);
                  auVar109 = VectorShiftLeft(auVar60,0x10,0x20,0);
                  auVar72 = VectorUnsignedFixedToFloat(auVar80,7);
                  VectorMultiply(auVar98._0_8_,uVar63,4,1);
                  auVar80 = VectorMultiply(auVar98._8_8_,uVar75,4,1);
                  VectorUnzip(auVar80,4);
                  auVar60 = VectorUnsignedFixedToFloat(auVar61,0x18);
                  auVar105 = VectorMin(auVar108,auVar89,4,1);
                  auVar113 = VectorAdd(auVar113,auVar60,4);
                  auVar98 = VectorShiftLeft(auVar105,0x10,0x20,0);
                  auVar60 = VectorMin(auVar113,auVar89,4,1);
                  auVar113 = VectorUnsignedFixedToFloat(auVar80,7);
                  auVar105 = VectorShiftLeft(auVar60,0x18,0x20,0);
                  VectorMultiply(auVar54._0_8_,uVar63,4,1);
                  auVar80 = VectorMultiply(auVar54._8_8_,uVar75,4,1);
                  VectorMultiply(auVar88._0_8_,uVar63,4,1);
                  VectorUnzip(auVar80,4);
                  auVar54 = VectorMultiply(auVar88._8_8_,uVar75,4,1);
                  auVar117 = VectorUnsignedFixedToFloat(auVar80,7);
                  VectorUnzip(auVar54,4);
                  auVar80._8_8_ = uStack_1c8;
                  auVar80._0_8_ = *puVar33;
                  auVar80 = VectorUnsignedFixedToFloat(auVar80,0x18);
                  auVar60 = VectorUnsignedFixedToFloat(auVar54,7);
                  auVar80 = VectorAdd(auVar107,auVar80,4);
                  auVar80 = VectorMin(auVar80,auVar89,4,1);
                  auVar88 = VectorShiftLeft(auVar80,0x18,0x20,0);
                  VectorMultiply(auVar87._0_8_,uVar63,4,1);
                  auVar87 = VectorMultiply(auVar87._8_8_,uVar75,4,1);
                  VectorMultiply(auVar114._0_8_,uVar63,4,1);
                  VectorUnzip(auVar87,4);
                  auVar80 = VectorMultiply(auVar114._8_8_,uVar75,4,1);
                  auVar108 = VectorUnsignedFixedToFloat(auVar87,7);
                  VectorUnzip(auVar80,4);
                  auVar107._8_8_ = local_1b8;
                  auVar107._0_8_ = *puVar13;
                  auVar54 = VectorUnsignedFixedToFloat(auVar80,7);
                  auVar87 = VectorUnsignedFixedToFloat(auVar107,0x18);
                  auVar87 = VectorAdd(auVar97,auVar87,4);
                  auVar87 = VectorMin(auVar87,auVar89,4,1);
                  auVar114 = VectorShiftLeft(auVar87,0x18,0x20,0);
                  VectorMultiply(auVar56._0_8_,uVar63,4,1);
                  auVar87 = VectorMultiply(auVar56._8_8_,uVar75,4,1);
                  VectorMultiply(auVar62._0_8_,uVar63,4,1);
                  VectorUnzip(auVar87,4);
                  auVar80 = VectorMultiply(auVar62._8_8_,uVar75,4,1);
                  auVar97 = VectorUnsignedFixedToFloat(auVar87,7);
                  auVar62._8_8_ = local_1a8;
                  auVar62._0_8_ = *puVar28;
                  VectorUnzip(auVar80,4);
                  auVar56 = VectorUnsignedFixedToFloat(auVar62,8);
                  auVar87 = VectorUnsignedFixedToFloat(auVar80,7);
                  auVar80 = VectorAdd(auVar113,auVar56 & auVar89,4);
                  auVar80 = VectorMin(auVar80,auVar89,4,1);
                  auVar113 = VectorUnsignedFixedToFloat(auVar61,8);
                  auVar56 = VectorShiftLeft(auVar80,8,0x20,0);
                  auVar80 = VectorAdd(auVar60,auVar113 & auVar89,4);
                  auVar113._8_8_ = uStack_1c8;
                  auVar113._0_8_ = *puVar33;
                  auVar80 = VectorMin(auVar80,auVar89,4,1);
                  auVar113 = VectorUnsignedFixedToFloat(auVar113,8);
                  auVar107 = VectorShiftLeft(auVar80,8,0x20,0);
                  auVar80 = VectorAdd(auVar54,auVar113 & auVar89,4);
                  auVar60._8_8_ = local_1b8;
                  auVar60._0_8_ = *puVar13;
                  auVar80 = VectorMin(auVar80,auVar89,4,1);
                  auVar54 = VectorUnsignedFixedToFloat(auVar60,8);
                  auVar113 = VectorShiftLeft(auVar80,8,0x20,0);
                  auVar87 = VectorAdd(auVar87,auVar54 & auVar89,4);
                  auVar87 = VectorMin(auVar87,auVar89,4,1);
                  auVar54 = VectorAdd(auVar72,auVar62 & auVar89,4);
                  auVar80 = VectorShiftLeft(auVar87,8,0x20,0);
                  auVar87 = VectorMin(auVar54,auVar89,4,1);
                  auVar87 = VectorBitwiseInsertIfTrue
                                      (auVar81 | auVar96 | auVar87 | auVar56,auVar62,
                                       auVar115 | auVar104);
                  auVar54 = VectorAdd(auVar117,auVar61 & auVar89,4);
                  *puVar27 = auVar87._0_8_;
                  puVar27[1] = auVar87._8_8_;
                  auVar87 = VectorMin(auVar54,auVar89,4,1);
                  puVar28 = puVar27 + 8;
                  auVar54._8_8_ = uStack_1c8;
                  auVar54._0_8_ = *puVar33;
                  auVar61 = VectorBitwiseInsertIfTrue
                                      (auVar116 | auVar105 | auVar87 | auVar107,auVar61,
                                       auVar103 | auVar4);
                  *(longlong *)*(undefined1 (*) [16])(puVar27 + 2) = auVar61._0_8_;
                  puVar27[3] = auVar61._8_8_;
                  auVar87 = VectorAdd(auVar108,auVar54 & auVar89,4);
                  auVar61._8_8_ = local_1b8;
                  auVar61._0_8_ = uVar76;
                  auVar87 = VectorMin(auVar87,auVar89,4,1);
                  auVar87 = VectorBitwiseInsertIfTrue
                                      (auVar109 | auVar88 | auVar87 | auVar113,auVar54,
                                       auVar95 | auVar4);
                  *puVar33 = auVar87._0_8_;
                  puVar27[5] = auVar87._8_8_;
                  auVar87 = VectorAdd(auVar97,auVar61 & auVar89,4);
                  auVar87 = VectorMin(auVar87,auVar89,4,1);
                  auVar61 = VectorBitwiseInsertIfTrue
                                      (auVar98 | auVar114 | auVar87 | auVar80,auVar61,
                                       auVar79 | auVar4);
                  *puVar13 = auVar61._0_8_;
                  puVar27[7] = auVar61._8_8_;
                  puVar27 = puVar28;
                } while (puVar28 != puVar50 + ((uint)puVar44 >> 4) * 8);
                auVar58._8_8_ = SUB168(auVar115 | auVar104,8);
                if (((uint)puVar44 & 0xf) != 0) {
                  puVar32 = puVar44 + -((uint)puVar44 & 0xfffffff0);
                  uVar10 = (uint)puVar44 & 0xfffffff0;
                  if ((undefined1 *)0x6 < puVar32 + -1) goto LAB_00b6ff28;
                  iVar24 = 0x10;
                  goto LAB_00b70294;
                }
              }
              pauVar48 = pauVar48 + 2;
              puVar50 = (undefined8 *)((int)puVar50 + uVar30 * 4);
              local_c0 = local_c0 + 1;
            } while (local_c0 < uVar19);
          }
          piVar21 = (int *)piVar21[2];
        } while (piVar21 != (int *)0x0);
      }
    }
    else if (piVar21 != (int *)0x0) {
      do {
        iVar23 = *piVar21;
        local_1a0 = piVar21 + 4;
        iVar24 = piVar21[1];
        pbVar15 = (byte *)(*(int *)(uVar8 + 0xc) - iVar23);
        uVar19 = *(int *)(uVar8 + 0x10) - iVar24;
        if (&DAT_0000001f < pbVar15) {
          pbVar15 = &DAT_00000020;
        }
        if (0x1f < uVar19) {
          uVar19 = 0x20;
        }
        iVar31 = iVar20 + (uVar30 * iVar24 + iVar23) * 4;
        if ((*(int *)(uVar8 + 0x10) != iVar24) && (*(int *)(uVar8 + 0xc) != iVar23)) {
          iVar23 = (iVar23 + -0x10) - (int)piVar21;
          local_1b0 = 0;
          do {
            puVar35 = (uint *)(iVar31 + -4);
            bVar3 = (&DAT_011dd648)[iVar24 + local_1b0 & 0xff];
            pbVar39 = (byte *)((int)local_1a0 + -1);
            do {
              while( true ) {
                pbVar25 = pbVar39 + iVar23 + 1;
                pbVar39 = pbVar39 + 1;
                puVar35 = puVar35 + 1;
                uVar9 = *puVar35;
                uVar10 = ~(~((uint)(byte)(&DAT_011dd648)[(uint)bVar3 + ((uint)pbVar25 & 0xff)] <<
                            0x1c) >> 0x1c) & (uint)*pbVar39;
                if (uVar10 != 0 && 0xffffff < uVar49) break;
                if (pbVar15 <= pbVar39 + (1 - (int)local_1a0)) goto LAB_00b6f72c;
              }
              uVar46 = ((uVar9 << 8) >> 0x18) + (uVar10 * uVar43) / 0xff;
              if (0xfe < uVar46) {
                uVar46 = 0xff;
              }
              uVar11 = (uVar9 >> 0x18) + (uVar10 * uVar40) / 0xff;
              if (0xfe < uVar11) {
                uVar11 = 0xff;
              }
              uVar11 = uVar11 << 0x18 | uVar46 << 0x10;
              uVar46 = (uVar9 & 0xff) + (uVar10 * uVar34) / 0xff;
              if (uVar46 < 0x100) {
                uVar11 = uVar11 | uVar46;
              }
              else {
                uVar11 = uVar11 | 0xff;
              }
              uVar10 = ((uVar9 << 0x10) >> 0x18) + (uVar10 * uVar29) / 0xff;
              if (0xfe < uVar10) {
                uVar10 = 0xff;
              }
              *puVar35 = uVar11 | uVar10 << 8;
            } while (pbVar39 + (1 - (int)local_1a0) < pbVar15);
LAB_00b6f72c:
            iVar23 = iVar23 + -0x20;
            iVar31 = iVar31 + uVar30 * 4;
            local_1b0 = local_1b0 + 1;
            local_1a0 = local_1a0 + 8;
          } while (local_1b0 < uVar19);
        }
        piVar21 = (int *)piVar21[2];
      } while (piVar21 != (int *)0x0);
    }
  }
  return;
}

