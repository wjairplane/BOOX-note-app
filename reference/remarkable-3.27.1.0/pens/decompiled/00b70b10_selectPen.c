
int * FUN_00b70b10(int *param_1,int param_2,uint param_3,int param_4,undefined4 param_5,
                  float param_6,undefined4 param_7)

{
  undefined8 uVar1;
  byte bVar2;
  char cVar3;
  uint uVar4;
  int iVar5;
  undefined4 uVar6;
  undefined1 uVar7;
  uint uVar8;
  undefined1 uVar9;
  uint uVar10;
  ushort *puVar11;
  float *pfVar12;
  float fVar13;
  undefined2 *puVar14;
  uint uVar15;
  undefined1 *puVar16;
  uint uVar17;
  uint uVar18;
  ushort uVar19;
  ushort uVar20;
  bool bVar21;
  double dVar22;
  double extraout_d1;
  float extraout_s13;
  float fVar23;
  undefined8 local_40;
  undefined8 local_38;
  undefined4 local_30;
  
  bVar2 = *(byte *)(param_2 + 0xa4);
  uVar19 = (ushort)bVar2;
  if (param_3 < 0x16) {
    if ((0x3a0010U >> (param_3 & 0xff) & 1) == 0) {
      if (param_3 != 0 || param_4 != 1) goto LAB_00b70d00;
      uVar4 = FUN_0014cea0(param_2 + 0x18,0,1,param_5);
      if (bVar2 == 0) {
        uVar20 = (ushort)((uVar4 << 0x18) >> 0x1b) | (ushort)(uVar4 >> 5) & 0x7e0 |
                 (ushort)(uVar4 >> 8) & 0xf800;
        puVar11 = *(ushort **)(param_2 + 0x47c);
        goto LAB_00b70dfc;
      }
      if (uVar4 < 0xff000000) goto LAB_00b70b8c;
      puVar16 = *(undefined1 **)(param_2 + 0x484);
      uVar18 = uVar4;
LAB_00b70d64:
      uVar9 = 2;
      uVar7 = 1;
    }
    else {
      uVar4 = FUN_0014cea0(param_2 + 0x18,param_3,param_4,param_5);
      if (bVar2 == 0) {
        uVar20 = (ushort)(uVar4 >> 5) & 0x7e0 | (ushort)((uVar4 << 0x18) >> 0x1b) |
                 (ushort)(uVar4 >> 8) & 0xf800;
        if (param_3 == 5) {
          uVar19 = 0x100;
        }
        puVar11 = *(ushort **)(param_2 + 0x47c);
        if ((param_3 == 5) || (param_3 == 0x12)) {
          *puVar11 = uVar19;
          goto LAB_00b70cbc;
        }
LAB_00b70dfc:
        *puVar11 = 0x201;
LAB_00b70cbc:
        if (*(int *)(param_2 + 0xb8) == 0x10) {
          iVar5 = FUN_00b6618c();
          if (*(char *)(iVar5 + 8) != '\0') {
            local_30 = *(undefined4 *)(iVar5 + 4);
            local_40 = DAT_00b71388;
            local_38 = 0;
            QMessageLogger::debug((char *)&local_40,"selected: pipelineV0 -> Solid::fill16");
          }
          *(ushort *)(param_2 + 0x148) = uVar20;
          *(int *)(*(int *)(param_2 + 0x47c) + 0x18) = param_2 + 0x13c;
        }
        else {
          iVar5 = FUN_00b6618c();
          if (*(char *)(iVar5 + 8) != '\0') {
            local_30 = *(undefined4 *)(iVar5 + 4);
            local_40 = DAT_00b71388;
            local_38 = 0;
            QMessageLogger::debug((char *)&local_40,"selected: pipelineV0 -> Solid::fill32");
          }
          *(uint *)(param_2 + 0x110) = uVar4;
          *(int *)(*(int *)(param_2 + 0x47c) + 0x18) = param_2 + 0x104;
        }
        *param_1 = param_2 + 0x478;
        *(undefined1 *)(param_1 + 1) = 0;
        *(undefined1 *)(param_1 + 2) = 1;
        return param_1;
      }
      uVar18 = uVar4;
      if (uVar4 < 0xff000000) {
LAB_00b70b8c:
        uVar18 = uVar4 >> 0x18;
        uVar10 = uVar4 & 0xff0000;
        uVar8 = uVar4 & 0xff;
        uVar15 = uVar18 * (uVar4 & 0xff00);
        uVar17 = uVar4 & 0xff000000;
        uVar4 = uVar15 * -0x7f7f7f7f;
        uVar18 = uVar17 | (uVar18 * uVar8) / 0xff | (uVar18 * uVar10) / 0xff & 0xff0000 |
                 uVar15 / 0xff & 0xff00;
      }
      puVar16 = *(undefined1 **)(param_2 + 0x484);
      if (param_3 == 5) {
        uVar9 = 1;
        uVar7 = 0;
      }
      else {
        if (param_3 != 0x12) goto LAB_00b70d64;
        uVar9 = 0;
        uVar7 = uVar9;
      }
    }
    puVar16[1] = uVar9;
    *puVar16 = uVar7;
    if (*(int *)(param_2 + 0xb8) == 0x10) {
      iVar5 = FUN_00b6618c(uVar4);
      if (*(char *)(iVar5 + 8) != '\0') {
        local_30 = *(undefined4 *)(iVar5 + 4);
        local_40 = DAT_00b71388;
        local_38 = 0;
        QMessageLogger::debug((char *)&local_40,"selected: pipelineV2 -> SolidAa::fill16");
      }
      iVar5 = *(int *)(param_2 + 0x484);
      *(uint *)(param_2 + 0x1d0) = uVar18;
      *(int *)(iVar5 + 0x18) = param_2 + 0x1c4;
      *(int *)(iVar5 + 0x30) = param_2 + 0x214;
    }
    else {
      iVar5 = FUN_00b6618c(uVar4);
      if (*(char *)(iVar5 + 8) != '\0') {
        local_30 = *(undefined4 *)(iVar5 + 4);
        local_40 = DAT_00b71388;
        local_38 = 0;
        QMessageLogger::debug((char *)&local_40,"selected: pipelineV2 -> SolidAa::fill32");
      }
      iVar5 = *(int *)(param_2 + 0x484);
      *(uint *)(param_2 + 0x180) = uVar18;
      *(int *)(iVar5 + 0x18) = param_2 + 0x174;
      *(int *)(iVar5 + 0x30) = param_2 + 0x214;
    }
    *param_1 = param_2 + 0x480;
    *(undefined1 *)(param_1 + 1) = 1;
    *(undefined1 *)(param_1 + 2) = 1;
  }
  else {
LAB_00b70d00:
    switch(param_3) {
    case 5:
    case 0x12:
      FUN_0014cea0(param_2 + 0x18,param_3,param_4,param_5);
      uVar4 = FUN_00b6d490();
      if (bVar2 == 0) {
        puVar16 = *(undefined1 **)(param_2 + 0x47c);
        puVar16[1] = param_3 == 5;
        *puVar16 = 0;
        if (param_4 == 8) {
          if (*(int *)(param_2 + 0xb8) == 0x10) {
            iVar5 = FUN_00b6618c();
            if (*(char *)(iVar5 + 8) != '\0') {
              local_30 = *(undefined4 *)(iVar5 + 4);
              local_40 = DAT_00b71550;
              local_38 = 0;
              QMessageLogger::debug
                        ((char *)&local_40,"selected: pipelineV0 -> Solid::fill16_srcover");
            }
            *(uint *)(param_2 + 0x16c) = uVar4;
            *(int *)(*(int *)(param_2 + 0x47c) + 0x18) = param_2 + 0x160;
          }
          else {
            iVar5 = FUN_00b6618c();
            if (*(char *)(iVar5 + 8) != '\0') {
              local_30 = *(undefined4 *)(iVar5 + 4);
              local_40 = DAT_00b71550;
              local_38 = 0;
              QMessageLogger::debug
                        ((char *)&local_40,"selected: pipelineV0 -> Solid::fill32_srcover");
            }
            *(uint *)(param_2 + 0x134) = uVar4;
            *(int *)(*(int *)(param_2 + 0x47c) + 0x18) = param_2 + 0x128;
          }
        }
        else if (*(int *)(param_2 + 0xb8) == 0x10) {
          iVar5 = FUN_00b6618c();
          if (*(char *)(iVar5 + 8) != '\0') {
            local_30 = *(undefined4 *)(iVar5 + 4);
            local_40 = DAT_00b71550;
            local_38 = 0;
            QMessageLogger::debug((char *)&local_40,"selected: pipelineV0 -> Solid::fill16_darken");
          }
          *(uint *)(param_2 + 0x158) = uVar4;
          *(int *)(*(int *)(param_2 + 0x47c) + 0x18) = param_2 + 0x14c;
        }
        else {
          iVar5 = FUN_00b6618c();
          if (*(char *)(iVar5 + 8) != '\0') {
            local_30 = *(undefined4 *)(iVar5 + 4);
            local_40 = DAT_00b71550;
            local_38 = 0;
            QMessageLogger::debug((char *)&local_40,"selected: pipelineV0 -> Solid::fill32_darken");
          }
          *(uint *)(param_2 + 0x120) = uVar4;
          *(int *)(*(int *)(param_2 + 0x47c) + 0x18) = param_2 + 0x114;
        }
        *param_1 = param_2 + 0x478;
        *(undefined1 *)(param_1 + 1) = 0;
        *(undefined1 *)(param_1 + 2) = 1;
      }
      else {
        puVar16 = *(undefined1 **)(param_2 + 0x484);
        puVar16[1] = param_3 == 5;
        *puVar16 = 0;
        if (param_4 == 8) {
          if (*(int *)(param_2 + 0xb8) == 0x10) {
            iVar5 = FUN_00b6618c();
            if (*(char *)(iVar5 + 8) != '\0') {
              local_30 = *(undefined4 *)(iVar5 + 4);
              local_40 = DAT_00b71550;
              local_38 = 0;
              QMessageLogger::debug
                        ((char *)&local_40,"selected: pipelineV2 -> SolidAa::fill16_srcover");
            }
            *(uint *)(param_2 + 0x200) = uVar4 >> 0x18;
            iVar5 = *(int *)(param_2 + 0x484);
            *(uint *)(param_2 + 0x1fc) = uVar4;
            *(int *)(iVar5 + 0x18) = param_2 + 500;
            *(int *)(iVar5 + 0x30) = param_2 + 0x214;
          }
          else {
            iVar5 = FUN_00b6618c();
            if (*(char *)(iVar5 + 8) != '\0') {
              local_30 = *(undefined4 *)(iVar5 + 4);
              local_40 = DAT_00b71550;
              local_38 = 0;
              QMessageLogger::debug
                        ((char *)&local_40,"selected: pipelineV2 -> SolidAa::fill32_srcover");
            }
            *(uint *)(param_2 + 0x1b0) = uVar4 >> 0x18;
            iVar5 = *(int *)(param_2 + 0x484);
            *(uint *)(param_2 + 0x1ac) = uVar4;
            *(int *)(iVar5 + 0x18) = param_2 + 0x1a4;
            *(int *)(iVar5 + 0x30) = param_2 + 0x214;
          }
        }
        else if (*(int *)(param_2 + 0xb8) == 0x10) {
          iVar5 = FUN_00b6618c();
          if (*(char *)(iVar5 + 8) != '\0') {
            local_30 = *(undefined4 *)(iVar5 + 4);
            local_40 = DAT_00b71550;
            local_38 = 0;
            QMessageLogger::debug
                      ((char *)&local_40,"selected: pipelineV2 -> SolidAa::fill16_darken");
          }
          *(uint *)(param_2 + 0x1e0) = uVar4 >> 0x18;
          iVar5 = *(int *)(param_2 + 0x484);
          *(uint *)(param_2 + 0x1dc) = uVar4;
          *(int *)(iVar5 + 0x18) = param_2 + 0x1d4;
          *(int *)(iVar5 + 0x30) = param_2 + 0x214;
        }
        else {
          iVar5 = FUN_00b6618c();
          if (*(char *)(iVar5 + 8) != '\0') {
            local_30 = *(undefined4 *)(iVar5 + 4);
            local_40 = DAT_00b71550;
            local_38 = 0;
            QMessageLogger::debug
                      ((char *)&local_40,"selected: pipelineV2 -> SolidAa::fill32_darken");
          }
          *(uint *)(param_2 + 400) = uVar4 >> 0x18;
          iVar5 = *(int *)(param_2 + 0x484);
          *(uint *)(param_2 + 0x18c) = uVar4;
          *(int *)(iVar5 + 0x18) = param_2 + 0x184;
          *(int *)(iVar5 + 0x30) = param_2 + 0x214;
        }
        *param_1 = param_2 + 0x480;
        *(undefined1 *)(param_1 + 1) = 1;
        *(undefined1 *)(param_1 + 2) = 1;
      }
      break;
    default:
      *(undefined1 *)(param_1 + 2) = 0;
      break;
    case 8:
    case 10:
    case 0xb:
      puVar14 = *(undefined2 **)(param_2 + 0x5d8);
      *puVar14 = 0x201;
      iVar5 = *(int *)(*(int *)(param_2 + 0x5f8) + 0x80);
      *(undefined4 *)(param_2 + 0x604) = 0;
      *(float *)(param_2 + 0x600) = 1.0 / param_6;
      *(int *)(puVar14 + 0x18) = param_2 + 0x5fc;
      if (iVar5 == 0x10) {
        iVar5 = param_2 + 0x608;
      }
      else {
        iVar5 = param_2 + 0x618;
      }
      *(int *)(puVar14 + 0xc) = iVar5;
      *param_1 = param_2 + 0x5d4;
      *(undefined1 *)(param_1 + 1) = 6;
      *(undefined1 *)(param_1 + 2) = 1;
      break;
    case 0xd:
    case 0xe:
      FUN_0014cea0(param_2 + 0x18,param_3,param_4,param_5);
      uVar4 = FUN_00b6d490();
      puVar14 = *(undefined2 **)(param_2 + 0x514);
      *puVar14 = 0x201;
      iVar5 = *(int *)(param_2 + 0x518);
      *(int *)(puVar14 + 0x18) = param_2 + 0x51c;
      local_40 = 0;
      local_38 = 0;
      dVar22 = (double)QTransform::map((QPointF *)(iVar5 + 8));
      if (*(int *)(*(int *)(param_2 + 0x518) + 0x80) == 0x10) {
        *(ushort *)(param_2 + 0x558) =
             (ushort)(uVar4 >> 8) & 0xf800 | (ushort)(uVar4 >> 5) & 0x7e0 |
             (ushort)((uVar4 << 0x18) >> 0x1b);
        iVar5 = param_2 + 0x52c;
        *(ulonglong *)(param_2 + 0x548) = CONCAT44((float)extraout_d1,(float)dVar22);
      }
      else {
        *(uint *)(param_2 + 0x588) = uVar4;
        iVar5 = param_2 + 0x55c;
        *(float *)(param_2 + 0x578) = (float)dVar22;
        *(float *)(param_2 + 0x57c) = (float)extraout_d1;
      }
      *(int *)(*(int *)(param_2 + 0x514) + 0x18) = iVar5;
      *param_1 = param_2 + 0x510;
      *(undefined1 *)(param_1 + 1) = 3;
      *(undefined1 *)(param_1 + 2) = 1;
      break;
    case 0xf:
      FUN_0014cea0(param_2 + 0x18,0xf,param_4,param_5);
      uVar6 = FUN_00b6d490();
      puVar14 = *(undefined2 **)(param_2 + 0x48c);
      *puVar14 = 0x201;
      pfVar12 = *(float **)(param_2 + 0x490);
      fVar23 = *pfVar12;
      cVar3 = *(char *)(pfVar12 + 0x1b);
      fVar13 = pfVar12[0x20];
      *(int *)(puVar14 + 0x18) = param_2 + 0x494;
      *(float *)(param_2 + 0x498) = extraout_s13 / fVar23;
      fVar23 = 1.0 / fVar23;
      if (cVar3 == '\0') {
        bVar21 = fVar13 != 2.24208e-44;
        if (bVar21) {
          iVar5 = param_2 + 0x4a0;
          *(int *)(puVar14 + 0xc) = iVar5;
          *(undefined4 *)(param_2 + 0x4ac) = uVar6;
        }
        else {
          iVar5 = param_2 + 0x4b0;
          *(int *)(puVar14 + 0xc) = param_2 + 0x4b8;
          *(undefined4 *)(param_2 + 0x4c4) = uVar6;
        }
        if (bVar21) {
          *(float *)(iVar5 + 0x14) = fVar23;
        }
        if (!bVar21) {
          *(float *)(iVar5 + 0x1c) = fVar23;
        }
      }
      else {
        if (fVar13 == 2.24208e-44) {
          iVar5 = param_2 + 0x4f0;
          *(int *)(puVar14 + 0xc) = iVar5;
          *(undefined4 *)(param_2 + 0x4fc) = uVar6;
        }
        else {
          iVar5 = param_2 + 0x4d0;
          *(int *)(puVar14 + 0xc) = iVar5;
          *(undefined4 *)(param_2 + 0x4dc) = uVar6;
        }
        *(float *)(iVar5 + 0x1c) = fVar23;
      }
      *param_1 = param_2 + 0x488;
      *(undefined1 *)(param_1 + 1) = 5;
      *(undefined1 *)(param_1 + 2) = 1;
      break;
    case 0x16:
      puVar14 = *(undefined2 **)(param_2 + 0x62c);
      *puVar14 = 0x201;
      cVar3 = *(char *)(*(int *)(param_2 + 0x630) + 0x6e);
      if (*(int *)(*(int *)(param_2 + 0x630) + 0x80) == 0x10) {
        *(int *)(puVar14 + 0xc) = param_2 + 0x65c;
        if (cVar3 == '\0') {
          uVar1 = SIMDExpandImmediate(0,0xe,0xff);
          *(undefined8 *)(param_2 + 0x67c) = uVar1;
        }
        else {
          uVar1 = SIMDExpandImmediate(1,0xe,0xbe);
          *(undefined8 *)(param_2 + 0x67c) = uVar1;
        }
      }
      else {
        *(int *)(puVar14 + 0xc) = param_2 + 0x634;
        if (cVar3 == '\0') {
          uVar1 = SIMDExpandImmediate(0,0xe,0xff);
          *(undefined8 *)(param_2 + 0x654) = uVar1;
        }
        else {
          uVar1 = SIMDExpandImmediate(1,0xe,0xbe);
          *(undefined8 *)(param_2 + 0x654) = uVar1;
        }
      }
      *param_1 = param_2 + 0x628;
      *(undefined1 *)(param_1 + 1) = 0;
      *(undefined1 *)(param_1 + 2) = 1;
      break;
    case 0x17:
      FUN_0014cea0(param_2 + 0x18,0x17,param_4,param_5);
      uVar6 = FUN_00b6d490();
      puVar14 = *(undefined2 **)(param_2 + 0x590);
      *(undefined4 *)(param_2 + 0x594) = param_7;
      *(undefined4 *)(param_2 + 0x5d0) = uVar6;
      *(int *)(puVar14 + 0x18) = param_2 + 0x5bc;
      *(int *)(puVar14 + 0xc) = param_2 + 0x5c0;
      *puVar14 = 0x201;
      *param_1 = param_2 + 0x58c;
      *(undefined1 *)(param_1 + 1) = 4;
      *(undefined1 *)(param_1 + 2) = 1;
    }
  }
  return param_1;
}

