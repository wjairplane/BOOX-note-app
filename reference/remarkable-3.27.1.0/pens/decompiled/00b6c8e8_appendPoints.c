
/* WARNING: Heritage AFTER dead removal. Example location: s1 : 0x00b772c8 */
/* WARNING: Restarted to delay deadcode elimination for space: register */

void FUN_00b6c8e8(int *param_1,undefined8 *param_2,int param_3)

{
  byte bVar1;
  ushort uVar2;
  undefined1 auVar3 [16];
  undefined1 auVar4 [16];
  undefined1 auVar5 [16];
  undefined1 auVar6 [16];
  undefined1 auVar7 [16];
  undefined1 auVar8 [16];
  undefined8 uVar9;
  undefined8 uVar10;
  int iVar11;
  undefined4 uVar12;
  int iVar13;
  undefined2 *puVar14;
  int *piVar15;
  float fVar16;
  undefined4 uVar17;
  undefined1 uVar18;
  uint uVar19;
  int iVar20;
  uint uVar21;
  int iVar22;
  undefined4 uVar23;
  float fVar24;
  uint uVar25;
  float *pfVar26;
  undefined4 *puVar27;
  QPen *pQVar28;
  uint unaff_r8;
  void *pvVar29;
  uint unaff_r9;
  char *pcVar30;
  int iVar31;
  int iVar32;
  bool in_ZR;
  bool bVar33;
  uint in_fpscr;
  double in_d0;
  undefined8 in_d1;
  undefined8 extraout_d1;
  undefined8 extraout_d1_00;
  undefined8 extraout_d1_01;
  undefined8 extraout_d1_02;
  undefined8 extraout_d1_03;
  float fVar34;
  float fVar35;
  float extraout_s14;
  float extraout_s14_00;
  undefined4 extraout_s15;
  uint extraout_s15_00;
  float fVar36;
  float fVar37;
  float extraout_s15_01;
  float extraout_s15_02;
  float fVar38;
  float fVar39;
  float fVar40;
  float extraout_s15_03;
  float extraout_s15_04;
  float fVar41;
  undefined8 unaff_d9;
  undefined8 unaff_d10;
  float fVar42;
  float fVar43;
  undefined8 unaff_d11;
  undefined1 auVar44 [16];
  double dVar45;
  undefined4 in_stack_fffffe10;
  undefined4 in_stack_fffffe14;
  QPen aQStack_198 [4];
  QString aQStack_194 [12];
  undefined4 uStack_188;
  char *pcStack_184;
  QString aQStack_17c [12];
  undefined4 uStack_170;
  char *pcStack_16c;
  undefined4 uStack_168;
  QString aQStack_164 [8];
  float fStack_15c;
  int iStack_158;
  char *pcStack_154;
  float fStack_150;
  float fStack_14c;
  float fStack_148;
  float fStack_144;
  undefined8 uStack_140;
  undefined8 uStack_138;
  undefined8 uStack_130;
  undefined2 uStack_128;
  undefined2 uStack_126;
  undefined1 uStack_124;
  byte bStack_123;
  undefined2 uStack_122;
  undefined8 uStack_120;
  undefined8 uStack_118;
  undefined4 uStack_110;
  undefined4 uStack_10c;
  undefined4 uStack_108;
  undefined8 uStack_104;
  uint uStack_fc;
  undefined4 uStack_f8;
  undefined4 uStack_f4;
  undefined4 uStack_f0;
  undefined8 uStack_ec;
  undefined8 uStack_e4;
  QRegion aQStack_dc [4];
  ushort uStack_d8;
  undefined4 uStack_d4;
  float fStack_d0;
  float fStack_cc;
  float fStack_c8;
  float fStack_c4;
  float fStack_c0;
  undefined4 uStack_bc;
  uint uStack_b8;
  undefined4 uStack_b4;
  undefined4 uStack_b0;
  undefined4 uStack_ac;
  undefined4 uStack_a4;
  undefined4 uStack_a0;
  undefined4 uStack_9c;
  undefined4 uStack_98;
  undefined8 uStack_94;
  undefined8 uStack_8c;
  uint uStack_84;
  undefined1 uStack_80;
  undefined4 uStack_7c;
  undefined2 uStack_78;
  undefined2 uStack_76;
  uint uStack_74;
  int iStack_70;
  undefined4 uStack_6c;
  undefined4 uStack_68;
  undefined4 uStack_64;
  undefined4 uStack_60;
  undefined4 uStack_5c;
  float fStack_58;
  float fStack_54;
  undefined4 uStack_50;
  undefined2 uStack_4c;
  undefined2 uStack_4a;
  undefined4 *puStack_48;
  undefined4 uStack_44;
  undefined4 uStack_40;
  undefined4 uStack_3c;
  undefined8 uStack_38;
  undefined8 uStack_30;
  int iStack_28;
  
  puVar27 = (undefined4 *)*param_1;
  if (in_ZR) {
    puStack_48 = puVar27;
    FUN_00b6ae4c(&puStack_48);
    uStack_30._0_4_ = *(undefined4 *)(param_2 + 1);
    bVar33 = *(int *)((int)param_2 + 0x14) != 0;
    if (bVar33) {
      uVar25 = (uint)*(ushort *)(*(int *)(param_2 + 2) + 10);
      uStack_74 = extraout_s15_00;
    }
    else {
      uStack_74 = 0x3f800000;
      uVar25 = 0;
    }
    uStack_38._0_4_ = (undefined4)*param_2;
    uStack_38._4_4_ = (undefined4)((ulonglong)*param_2 >> 0x20);
    if (bVar33) {
      uStack_74 = uVar25;
    }
    iStack_28 = 1;
    if (bVar33) {
      uStack_74 = VectorFloatToUnsignedFixed(uStack_74,0x20,2);
    }
    uStack_78 = (undefined2)(undefined4)uStack_30;
    uStack_76 = (undefined2)((uint)(undefined4)uStack_30 >> 0x10);
    iStack_70 = 1;
    uStack_30._4_4_ = uStack_74;
    FUN_00b70b10(&uStack_68,puVar27,(undefined4)uStack_38,uStack_38._4_4_);
    puVar27[7] = uStack_68;
    puVar27[8] = uStack_64;
    puVar27[9] = uStack_60;
    FUN_00b6bed4(&puStack_48,param_2);
    FUN_00b6ae4c(&puStack_48);
    return;
  }
  iVar11 = QImage::isNull();
  if (iVar11 != 0) {
    return;
  }
  if (*(int *)((int)param_2 + 0x14) * 0xe == 0) {
    return;
  }
  iVar11 = FUN_00b5f574(param_2);
  if (iVar11 == 1) {
    uStack_30._0_4_ = *(undefined4 *)(param_2 + 1);
    bVar33 = *(int *)((int)param_2 + 0x14) != 0;
    if (bVar33) {
      uVar25 = (uint)*(ushort *)(*(int *)(param_2 + 2) + 10);
      uStack_74 = extraout_s15;
    }
    else {
      uStack_74 = 0x3f800000;
      uVar25 = 0;
    }
    uStack_38._0_4_ = (undefined4)*param_2;
    uStack_38._4_4_ = (undefined4)((ulonglong)*param_2 >> 0x20);
    if (bVar33) {
      uStack_74 = VectorFloatToUnsignedFixed(uVar25,0x20,2);
    }
    uStack_78 = (undefined2)(undefined4)uStack_30;
    uStack_76 = (undefined2)((uint)(undefined4)uStack_30 >> 0x10);
    iStack_70 = param_3;
    uStack_30._4_4_ = uStack_74;
    iStack_28 = param_3;
    FUN_00b70b10(&uStack_68,puVar27,(undefined4)uStack_38,uStack_38._4_4_);
    puVar27[7] = uStack_68;
    puVar27[8] = uStack_64;
    puVar27[9] = uStack_60;
    if (*(char *)(puVar27 + 9) != '\0') {
      fVar37 = *(float *)(param_2 + 4);
      switch(*(undefined1 *)(puVar27 + 8)) {
      case 0:
      case 1:
        piVar15 = (int *)puVar27[7];
        fVar41 = 0.75;
        if (*(char *)(puVar27 + 0x29) == '\0') {
          fVar41 = DAT_00b6cce0;
        }
        *(float *)(piVar15[1] + 0x38) = fVar37 * (float)puVar27[0xe];
        break;
      case 2:
        piVar15 = (int *)puVar27[7];
        fVar41 = DAT_00b6cce0;
        if (*(char *)(puVar27 + 0x29) != '\0') {
          fVar41 = 0.75;
        }
        *(float *)(piVar15[1] + 0x38) = fVar37 * (float)puVar27[0xe];
        break;
      case 3:
        iVar11 = puVar27[7];
        fVar41 = 0.75;
        if (*(char *)(puVar27 + 0x29) == '\0') {
          fVar41 = DAT_00b6cce0;
        }
        *(float *)(*(int *)(iVar11 + 4) + 0x38) = fVar37 * (float)puVar27[0xe];
        goto LAB_00b6cd98;
      case 4:
        iVar11 = puVar27[7];
        fVar41 = 0.75;
        if (*(char *)(puVar27 + 0x29) == '\0') {
          fVar41 = DAT_00b6cce0;
        }
        *(float *)(*(int *)(iVar11 + 4) + 0x38) = fVar37 * (float)puVar27[0xe];
        goto LAB_00b6cb68;
      case 5:
        iVar11 = puVar27[7];
        fVar41 = 0.75;
        if (*(char *)(puVar27 + 0x29) == '\0') {
          fVar41 = DAT_00b6cce0;
        }
        *(float *)(*(int *)(iVar11 + 4) + 0x38) = fVar37 * (float)puVar27[0xe];
        goto LAB_00b6ccec;
      default:
        iVar11 = puVar27[7];
        fVar41 = 0.75;
        if (*(char *)(puVar27 + 0x29) == '\0') {
          fVar41 = DAT_00b6cce0;
        }
        *(float *)(*(int *)(iVar11 + 4) + 0x38) = fVar37 * (float)puVar27[0xe];
        goto LAB_00b6cc14;
      }
      goto LAB_00b6ca20;
    }
  }
  else if (*(char *)(puVar27 + 9) != '\0') {
    fVar41 = DAT_00b6cce0;
    if (*(char *)(puVar27 + 0x29) != '\0') {
      fVar41 = 0.75;
    }
    switch(*(undefined1 *)(puVar27 + 8)) {
    case 0:
    case 1:
    case 2:
      piVar15 = (int *)puVar27[7];
      break;
    case 3:
      iVar11 = puVar27[7];
LAB_00b6cd98:
      iVar13 = *(int *)((int)param_2 + 0x14) * 0xe + -0xe;
      iVar31 = *(int *)(param_2 + 2) + iVar13;
      bVar1 = *(byte *)(iVar31 + 0xd);
      uVar2 = *(ushort *)(iVar31 + 10);
      uStack_38 = (double)*(float *)(*(int *)(param_2 + 2) + iVar13);
      uStack_30 = (double)*(float *)(iVar31 + 4);
      dVar45 = (double)QTransform::map((QPointF *)(puVar27 + 0x10));
      fVar37 = (float)puVar27[0xe];
      fVar24 = (float)VectorUnsignedToFloat((uint)bVar1,(byte)(in_fpscr >> 0x15) & 3);
      fVar36 = (float)VectorFloatToUnsignedFixed((uint)uVar2,0x20,2);
      puStack_48 = SUB84(dVar45,0);
      uStack_44 = (undefined4)((ulonglong)dVar45 >> 0x20);
      uStack_40 = (undefined4)extraout_d1_03;
      uStack_3c = (undefined4)((ulonglong)extraout_d1_03 >> 0x20);
      *(float *)(iVar11 + 0x10) = DAT_00b6ccdc + (fVar24 / DAT_00b6ccd4) * DAT_00b6ccd8;
      *(float *)(*(int *)(iVar11 + 4) + 4) = fVar41 + fVar36 * fVar37;
      FUN_00b7cb3c((float)dVar45);
      if ((*(char *)(*(int *)(iVar11 + 4) + 0xe4) == '\0') &&
         (*(char *)(*(int *)(iVar11 + 4) + 0x6c) == '\x02')) {
        FUN_00b6aa5c();
        return;
      }
      return;
    case 4:
      iVar11 = puVar27[7];
LAB_00b6cb68:
      iVar31 = *(int *)((int)param_2 + 0x14) * 0xe + -0xe;
      iVar13 = *(int *)(param_2 + 2) + iVar31;
      fStack_58 = *(float *)(*(int *)(param_2 + 2) + iVar31);
      fStack_54 = *(float *)(iVar13 + 4);
      uStack_50 = *(undefined4 *)(iVar13 + 8);
      uStack_4c = *(undefined2 *)(iVar13 + 0xc);
      uStack_30 = (double)fStack_54;
      uVar2 = *(ushort *)(iVar13 + 10);
      uStack_38 = (double)fStack_58;
      dVar45 = (double)QTransform::map((QPointF *)(puVar27 + 0x10));
      fVar37 = (float)VectorFloatToUnsignedFixed((uint)uVar2,0x20,2);
      uStack_78 = uStack_4c;
      puStack_48 = SUB84(dVar45,0);
      uStack_44 = (undefined4)((ulonglong)dVar45 >> 0x20);
      uStack_40 = (undefined4)extraout_d1_00;
      uStack_3c = (undefined4)((ulonglong)extraout_d1_00 >> 0x20);
      FUN_00b74fac((float)dVar45,uStack_44,fVar41 + fVar37 * (float)puVar27[0xe],iVar11,fStack_58,
                   fStack_54,uStack_50);
      return;
    case 5:
      iVar11 = puVar27[7];
LAB_00b6ccec:
      iVar31 = *(int *)((int)param_2 + 0x14) * 0xe + -0xe;
      iVar13 = *(int *)(param_2 + 2) + iVar31;
      fStack_58 = *(float *)(*(int *)(param_2 + 2) + iVar31);
      fStack_54 = *(float *)(iVar13 + 4);
      uStack_50 = *(undefined4 *)(iVar13 + 8);
      uStack_4c = *(undefined2 *)(iVar13 + 0xc);
      uStack_30 = (double)fStack_54;
      uVar2 = *(ushort *)(iVar13 + 10);
      uStack_38 = (double)fStack_58;
      dVar45 = (double)QTransform::map((QPointF *)(puVar27 + 0x10));
      fVar37 = (float)VectorFloatToUnsignedFixed((uint)uVar2,0x20,2);
      uStack_78 = uStack_4c;
      puStack_48 = SUB84(dVar45,0);
      uStack_44 = (undefined4)((ulonglong)dVar45 >> 0x20);
      uStack_40 = (undefined4)extraout_d1_02;
      uStack_3c = (undefined4)((ulonglong)extraout_d1_02 >> 0x20);
      FUN_00b7a7bc((float)dVar45,uStack_44,fVar41 + fVar37 * (float)puVar27[0xe],iVar11,fStack_58,
                   fStack_54,uStack_50);
      return;
    case 6:
      iVar11 = puVar27[7];
LAB_00b6cc14:
      iVar13 = *(int *)((int)param_2 + 0x14) * 0xe + -0xe;
      iVar31 = *(int *)(param_2 + 2) + iVar13;
      uVar2 = *(ushort *)(iVar31 + 10);
      uStack_38 = (double)*(float *)(*(int *)(param_2 + 2) + iVar13);
      uStack_30 = (double)*(float *)(iVar31 + 4);
      dVar45 = (double)QTransform::map((QPointF *)(puVar27 + 0x10));
      fVar24 = **(float **)(iVar11 + 0x24);
      fVar37 = (float)puVar27[0xe];
      fVar36 = (float)VectorFloatToUnsignedFixed((uint)uVar2,0x20,2);
      fVar41 = fVar41 + fVar36 * fVar37;
      if (fVar24 != 0.0) {
        fVar37 = 1.0;
      }
      puStack_48 = SUB84(dVar45,0);
      uStack_44 = (undefined4)((ulonglong)dVar45 >> 0x20);
      uStack_40 = (undefined4)extraout_d1_01;
      uStack_3c = (undefined4)((ulonglong)extraout_d1_01 >> 0x20);
      if (fVar24 != 0.0) {
        fVar41 = fVar41 * (fVar37 / fVar24);
      }
      *(float *)(*(int *)(iVar11 + 4) + 4) = fVar41;
      FUN_00b7a084((float)dVar45);
      if (*(char *)(*(int *)(iVar11 + 4) + 0xc4) != '\0') {
        return;
      }
      if (*(char *)(*(int *)(iVar11 + 4) + 0x5c) != '\x02') {
        return;
      }
      FUN_00b6a38c();
      return;
    default:
      FUN_00b6ae4c(&puStack_48);
                    /* WARNING: Subroutine does not return */
      __cxa_end_cleanup();
    }
LAB_00b6ca20:
    iVar11 = *(int *)((int)param_2 + 0x14) * 0xe + -0xe;
    iVar31 = *(int *)(param_2 + 2) + iVar11;
    fStack_58 = *(float *)(*(int *)(param_2 + 2) + iVar11);
    fStack_54 = *(float *)(iVar31 + 4);
    uStack_50 = *(undefined4 *)(iVar31 + 8);
    uStack_4c = *(undefined2 *)(iVar31 + 0xc);
    uStack_30 = (double)fStack_54;
    uVar2 = *(ushort *)(iVar31 + 10);
    uStack_38 = (double)fStack_58;
    dVar45 = (double)QTransform::map((QPointF *)(puVar27 + 0x10));
    fVar37 = (float)VectorFloatToUnsignedFixed((uint)uVar2,0x20,2);
    uStack_78 = uStack_4c;
    puStack_48 = SUB84(dVar45,0);
    uStack_44 = (undefined4)((ulonglong)dVar45 >> 0x20);
    uStack_40 = (undefined4)extraout_d1;
    uStack_3c = (undefined4)((ulonglong)extraout_d1 >> 0x20);
    (**(code **)(*piVar15 + 8))
              ((float)dVar45,uStack_44,fVar41 + fVar37 * (float)puVar27[0xe],piVar15,fStack_58,
               fStack_54,uStack_50);
    return;
  }
  pcVar30 = *(char **)param_2;
  uStack_4c = (undefined2)unaff_d9;
  uStack_4a = (undefined2)((ulonglong)unaff_d9 >> 0x10);
  puStack_48 = (undefined4 *)((ulonglong)unaff_d9 >> 0x20);
  uStack_44 = (undefined4)unaff_d10;
  uStack_40 = (undefined4)((ulonglong)unaff_d10 >> 0x20);
  uStack_3c = (undefined4)unaff_d11;
  uStack_38._0_4_ = (undefined4)((ulonglong)unaff_d11 >> 0x20);
  if (pcVar30 != (char *)0x0) {
    uVar17 = (undefined4)((ulonglong)in_d0 >> 0x20);
    switch(pcVar30) {
    case (char *)0x1:
      iVar11 = FUN_00b6618c();
      if (*(char *)(iVar11 + 8) != '\0') {
        uStack_110 = *(undefined4 *)(iVar11 + 4);
        uStack_120 = DAT_00b81fd8;
        uStack_118 = 0;
        uVar12 = FUN_00b5f574(param_2);
        QMessageLogger::debug
                  ((char *)&uStack_120,"renderPencil: pointCount=%d, mode=%d, color=%d",uVar12,
                   param_3);
      }
      dVar45 = *(double *)(puVar27 + 0x1e);
      fVar41 = (float)*(double *)(puVar27 + 0x1c);
      fVar37 = (float)puVar27[0xe];
      iVar11 = FUN_00b5f574(param_2,param_2,param_3,0);
      bVar33 = param_3 == 0;
      uStack_b4 = 0;
      uStack_b0 = 0;
      uStack_5c = 0;
      fStack_58 = 0.0;
      if (bVar33) {
        unaff_r9 = iVar11 - 3;
      }
      uStack_104 = 0;
      uStack_120 = 0x3f80000000000000;
      uStack_10c = 0;
      uStack_ec = 0;
      uStack_e4 = 0;
      uStack_108 = 0;
      uStack_fc = 0xff000000;
      uStack_f8 = 0;
      uStack_f4 = 0;
      if (!bVar33) {
        unaff_r9 = 0;
      }
      uStack_f0 = 1;
      if (bVar33) {
        unaff_r9 = unaff_r9 & ~((int)unaff_r9 >> 0x1f);
      }
      QRegion::QRegion(aQStack_dc);
      fStack_c0 = 0.0;
      uStack_78 = (undefined2)uStack_b0;
      uStack_76 = (undefined2)((uint)uStack_b0 >> 0x10);
      uStack_d4 = 0;
      uStack_bc = (uint)(ushort)uStack_bc;
      uStack_b8 = uStack_b8 & 0xffffff00;
      uStack_84 = (uint)(ushort)uStack_84;
      uStack_80 = 0;
      fStack_d0 = (float)DAT_00b76e80;
      fStack_cc = (float)((ulonglong)DAT_00b76e80 >> 0x20);
      fStack_c8 = (float)DAT_00b76e88;
      fStack_c4 = (float)((ulonglong)DAT_00b76e88 >> 0x20);
      uStack_94 = DAT_00b76e90;
      uStack_8c = DAT_00b76e98;
      uStack_a4 = uStack_b4;
      uStack_a0 = uStack_b0;
      uStack_7c = uStack_b4;
      uStack_6c = uStack_b4;
      uStack_68 = uStack_b0;
      uStack_108 = QImage::constBits();
      uVar12 = QImage::bytesPerLine();
      uStack_104 = CONCAT44(uStack_104._4_4_,uVar12);
      uVar12 = QImage::depth();
      fStack_15c = (float)puVar27[0x25];
      pcStack_154 = (char *)puVar27[0x26];
      iStack_158 = puVar27[0x27];
      uStack_104 = CONCAT44(uVar12,(undefined4)uStack_104);
      fVar24 = (float)puVar27[0x24];
      iVar31 = QRegion::isEmpty();
      if (iVar31 == 0) {
        QRegion::operator=(aQStack_dc,(QRegion *)(puVar27 + 0x28));
      }
      else {
        uStack_138._0_4_ = fStack_15c;
        uStack_140._4_4_ = (float)((int)pcStack_154 + 1);
        uStack_138._4_4_ = (float)(iStack_158 + 1);
        auVar6._4_4_ = uStack_140._4_4_;
        auVar6._0_4_ = fVar24;
        auVar6._8_4_ = fStack_15c;
        auVar6._12_4_ = uStack_138._4_4_;
        auVar44 = VectorSignedToFloat(auVar6,8);
        uStack_ec = auVar44._0_8_;
        uStack_e4 = auVar44._8_8_;
        uStack_140._0_4_ = fVar24;
      }
      uStack_fc = FUN_0014cea0(puVar27 + 6,*(undefined4 *)param_2,*(undefined4 *)((int)param_2 + 4),
                               *(undefined4 *)(param_2 + 1));
      fVar36 = DAT_00b76ea4;
      fVar24 = DAT_00b76ea0;
      bVar33 = param_3 == 1;
      fVar39 = extraout_s15_01;
      if (bVar33) {
        fVar39 = *(float *)(param_2 + 4);
      }
      if (bVar33) {
        fVar39 = fVar39 * (float)puVar27[0xe];
      }
      uStack_f8 = CONCAT22(uStack_f8._2_2_,
                           (ushort)(uStack_fc >> 8) & 0xf800 | (ushort)(uStack_fc >> 5) & 0x7e0 |
                           (ushort)((uStack_fc << 0x18) >> 0x1b));
      if (bVar33) {
        fStack_d0 = fVar39;
      }
      if ((int)(unaff_r9 + 2) < iVar11) {
        iVar31 = unaff_r9 * 0xe;
        fVar40 = 0.25;
        fVar39 = DAT_00b76ea8;
        do {
          iVar22 = *(int *)(param_2 + 2);
          iVar20 = iVar31 + 0x1c;
          pfVar26 = (float *)(iVar22 + iVar31);
          iVar13 = iVar22 + iVar31;
          iVar31 = iVar31 + 0xe;
          iVar32 = iVar22 + iVar20;
          fVar35 = *(float *)(iVar22 + iVar20);
          uStack_130._4_4_ = *(float *)(iVar32 + 4);
          fVar16 = *(float *)(iVar22 + iVar31);
          uStack_128 = (undefined2)*(undefined4 *)(iVar32 + 8);
          uStack_126 = (undefined2)((uint)*(undefined4 *)(iVar32 + 8) >> 0x10);
          uStack_124 = (undefined1)*(undefined2 *)(iVar32 + 0xc);
          bStack_123 = (byte)((ushort)*(undefined2 *)(iVar32 + 0xc) >> 8);
          fVar34 = (float)VectorUnsignedToFloat((uint)bStack_123,(byte)(in_fpscr >> 0x15) & 3);
          fVar38 = fVar35 + uStack_130._4_4_ + fVar24;
          uVar25 = ((uint)fVar38 ^ (uint)fVar38 >> 0x10) * 0x45d9f3b;
          uVar25 = (uVar25 ^ uVar25 >> 0x10) * 0x45d9f3b;
          uVar19 = (uVar25 ^ uVar25 >> 0x10) & 3;
          uVar25 = in_fpscr & 0xfffffff;
          in_fpscr = uVar25 | (uint)(fVar34 / fVar36 < 0.75) << 0x1f;
          if (SUB41(in_fpscr >> 0x1f,0)) {
            uStack_f4 = *(undefined4 *)(&DAT_013aeacc + uVar19 * 0xc);
          }
          else {
            in_fpscr = uVar25 | (uint)(fVar34 / fVar36 < fVar39) << 0x1f;
            iVar22 = uVar19 * 0xc;
            if (SUB41(in_fpscr >> 0x1f,0)) {
              uStack_f4 = *(undefined4 *)(&DAT_013aea9c + iVar22);
            }
            else {
              uStack_f4 = *(undefined4 *)(&DAT_013aeafc + iVar22);
            }
          }
          fVar34 = (float)VectorUnsignedToFloat
                                    ((uint)*(ushort *)(iVar32 + 10),(byte)(in_fpscr >> 0x15) & 3);
          fVar38 = fVar41 + *pfVar26 * fVar37;
          fVar42 = (float)dVar45 + *(float *)(iVar13 + 4) * fVar37;
          fVar34 = fVar34 * fVar40 * fVar37;
          uStack_120 = CONCAT44(fVar34,(undefined4)uStack_120);
          uStack_130._0_4_ = fVar35;
          if (uStack_bc._2_1_ == '\x02') {
            uVar12 = (undefined4)((ulonglong)dVar45 >> 0x20);
            if ((uStack_5c & 0xff) == 0) {
              FUN_00b6825c(uStack_7c,uVar17,uStack_74,uVar12,uStack_6c,uStack_68,uStack_64,uStack_60
                           ,&uStack_120);
              bVar33 = uStack_5c._1_1_ == '\0';
              uStack_5c = CONCAT31(uStack_5c._1_3_,1);
              if ((bVar33) && (uStack_bc._2_1_ == '\x02')) {
LAB_00b76e14:
                FUN_00b6825c(uStack_b4,uVar17,uStack_ac,uVar12,uStack_a4,uStack_a0,uStack_9c,
                             uStack_98,&uStack_120,1);
                uStack_5c._0_2_ = CONCAT11(1,(undefined1)uStack_5c);
                fVar34 = uStack_120._4_4_;
              }
              else {
                fVar34 = uStack_120._4_4_;
              }
            }
            else if (uStack_5c._1_1_ == '\0') goto LAB_00b76e14;
          }
          fStack_144 = fStack_d0;
          fStack_c0 = fStack_d0;
          uStack_b8 = CONCAT31(uStack_b8._1_3_,uStack_120._1_1_);
          uStack_bc._0_3_ = CONCAT12(1,(ushort)uStack_bc);
          uStack_bc = CONCAT13(uStack_120._0_1_,(undefined3)uStack_bc);
          uStack_94 = CONCAT44(fVar42,fVar38);
          uStack_8c = CONCAT44(fStack_d0,fVar34);
          uStack_84 = uStack_bc;
          uStack_80 = uStack_120._1_1_;
          fStack_150 = fVar38;
          fStack_14c = fVar42;
          fStack_148 = fVar34;
          fStack_cc = fVar38;
          fStack_c8 = fVar42;
          fStack_c4 = fVar34;
          FUN_00b76644(fVar41 + fVar16 * fVar37,&uStack_120);
          FUN_00b76644(fVar41 + fVar35 * fVar37,&uStack_120);
        } while (iVar31 != iVar11 * 0xe + -0x1c);
      }
      FUN_00b76860(&uStack_120);
      QRegion::~QRegion(aQStack_dc);
      return;
    case (char *)0x2:
    case (char *)0x18:
      iVar11 = FUN_00b6618c();
      if (*(char *)(iVar11 + 8) != '\0') {
        uStack_110 = *(undefined4 *)(iVar11 + 4);
        uStack_120 = DAT_00b77ae0;
        uStack_118 = 0;
        uVar12 = FUN_00b5f574(param_2);
        uStack_168 = *(undefined4 *)((int)param_2 + 4);
        QMessageLogger::debug
                  ((char *)&uStack_120,"renderBallPoint: pointCount=%d, mode=%d, color=%d",uVar12,
                   param_3);
      }
      fVar37 = (float)puVar27[0xe];
      dVar45 = *(double *)(puVar27 + 0x1e);
      fVar41 = (float)*(double *)(puVar27 + 0x1c);
      iVar11 = FUN_00b5f574(param_2);
      uStack_b4 = 0;
      uStack_b0 = 0;
      uStack_5c = 0;
      fStack_58 = 0.0;
      bVar33 = param_3 == 0;
      uStack_104 = 0;
      if (bVar33) {
        unaff_r9 = iVar11 - 2;
      }
      uStack_ec = 0;
      uStack_e4 = 0;
      uStack_120 = 0x3f80000000000000;
      uStack_fc = 0xff000000;
      uStack_10c = 0;
      if (!bVar33) {
        unaff_r9 = 0;
      }
      uStack_108 = 0;
      uStack_f8 = 0;
      uStack_f4 = 0;
      uStack_f0 = 1;
      if (bVar33) {
        unaff_r9 = unaff_r9 & ~((int)unaff_r9 >> 0x1f);
      }
      QRegion::QRegion(aQStack_dc);
      uStack_d4 = 0;
      fStack_c0 = 0.0;
      uStack_bc = (uint)(ushort)uStack_bc;
      uStack_b8 = uStack_b8 & 0xffffff00;
      uStack_84 = (uint)(ushort)uStack_84;
      uStack_80 = 0;
      fStack_d0 = (float)DAT_00b77850;
      fStack_cc = (float)((ulonglong)DAT_00b77850 >> 0x20);
      fStack_c8 = (float)DAT_00b77858;
      fStack_c4 = (float)((ulonglong)DAT_00b77858 >> 0x20);
      uStack_78 = (undefined2)uStack_b0;
      uStack_76 = (undefined2)((uint)uStack_b0 >> 0x10);
      uStack_94 = DAT_00b77860;
      uStack_8c = DAT_00b77868;
      uStack_a4 = uStack_b4;
      uStack_a0 = uStack_b0;
      uStack_7c = uStack_b4;
      uStack_6c = uStack_b4;
      uStack_68 = uStack_b0;
      uStack_108 = QImage::constBits();
      uVar12 = QImage::bytesPerLine();
      uStack_104 = CONCAT44(uStack_104._4_4_,uVar12);
      uVar12 = QImage::depth();
      pcStack_154 = (char *)puVar27[0x24];
      iStack_158 = puVar27[0x25];
      fStack_15c = (float)puVar27[0x27];
      uStack_104 = CONCAT44(uVar12,(undefined4)uStack_104);
      iVar13 = puVar27[0x26];
      iVar31 = QRegion::isEmpty();
      if (iVar31 == 0) {
        QRegion::operator=(aQStack_dc,(QRegion *)(puVar27 + 0x28));
      }
      else {
        uStack_130._4_4_ = (float)(iVar13 + 1);
        uStack_130._0_4_ = (float)pcStack_154;
        iVar31 = (int)fStack_15c + 1;
        uStack_124 = (undefined1)iVar31;
        bStack_123 = (byte)((uint)iVar31 >> 8);
        uStack_122 = (undefined2)((uint)iVar31 >> 0x10);
        uStack_128 = (undefined2)iStack_158;
        uStack_126 = (undefined2)((uint)iStack_158 >> 0x10);
        auVar8._4_4_ = uStack_130._4_4_;
        auVar8._0_4_ = pcStack_154;
        auVar8._8_2_ = uStack_128;
        auVar8._10_2_ = uStack_126;
        auVar8[0xc] = uStack_124;
        auVar8[0xd] = bStack_123;
        auVar8._14_2_ = uStack_122;
        auVar44 = VectorSignedToFloat(auVar8,8);
        uStack_ec = auVar44._0_8_;
        uStack_e4 = auVar44._8_8_;
      }
      uStack_fc = FUN_0014cea0(puVar27 + 6,*(undefined4 *)param_2,*(undefined4 *)((int)param_2 + 4),
                               *(undefined4 *)(param_2 + 1));
      fVar24 = DAT_00b77870;
      uStack_f8 = CONCAT22(uStack_f8._2_2_,
                           (ushort)(uStack_fc >> 8) & 0xf800 | (ushort)(uStack_fc >> 5) & 0x7e0 |
                           (ushort)((uStack_fc << 0x18) >> 0x1b));
      uVar12 = (undefined4)((ulonglong)in_d1 >> 0x20);
      if (param_3 == 1) {
        fStack_d0 = *(float *)(param_2 + 4) * (float)puVar27[0xe];
        uStack_120._0_2_ = CONCAT11(2,uStack_120._0_1_);
        if ((int)(unaff_r9 + 1) < iVar11) {
          iVar31 = unaff_r9 * 0xe;
          fVar40 = 0.25;
          fVar36 = DAT_00b77874;
          fVar39 = DAT_00b77878;
          do {
            iVar22 = *(int *)(param_2 + 2);
            pfVar26 = (float *)(iVar22 + iVar31);
            iVar13 = iVar22 + iVar31;
            iVar31 = iVar31 + 0xe;
            fVar42 = fVar41 + fVar37 * *pfVar26;
            fVar16 = *(float *)(iVar22 + iVar31);
            iVar22 = iVar22 + iVar31;
            fVar43 = (float)dVar45 + fVar37 * *(float *)(iVar13 + 4);
            fVar34 = (float)VectorUnsignedToFloat
                                      ((uint)*(byte *)(iVar22 + 0xd),(byte)(in_fpscr >> 0x15) & 3);
            fVar38 = fVar16 + *(float *)(iVar22 + 4) + fVar24;
            fVar35 = (float)VectorUnsignedToFloat
                                      ((uint)*(ushort *)(iVar22 + 10),(byte)(in_fpscr >> 0x15) & 3);
            uVar25 = ((uint)fVar38 ^ (uint)fVar38 >> 0x10) * 0x45d9f3b;
            uVar25 = (uVar25 ^ uVar25 >> 0x10) * 0x45d9f3b;
            fVar35 = fVar35 * fVar40 * fVar37;
            uStack_120 = CONCAT44(fVar35,(undefined4)uStack_120);
            uStack_f4 = (&DAT_013aea6c)[((uVar25 ^ uVar25 >> 0x10) & 3) * 3];
            in_fpscr = in_fpscr & 0xfffffff | (uint)(fVar34 / fVar36 < fVar39) << 0x1f;
            bVar33 = SUB41(in_fpscr >> 0x1f,0);
            uVar23 = uStack_f4;
            if (bVar33) {
              uVar23 = 1;
            }
            uVar18 = (undefined1)uVar23;
            if (!bVar33) {
              uVar18 = 0;
            }
            uStack_f0 = CONCAT31(uStack_f0._1_3_,uVar18);
            if (uStack_bc._2_1_ == '\x02') {
              if ((uStack_5c & 0xff) == 0) {
                FUN_00b6825c(uStack_7c,uVar17,uStack_74,uVar12,uStack_6c,uStack_68,uStack_64,
                             uStack_60,&uStack_120);
                bVar33 = uStack_5c._1_1_ == '\0';
                uStack_5c = CONCAT31(uStack_5c._1_3_,1);
                if ((bVar33) && (uStack_bc._2_1_ == '\x02')) {
LAB_00b77a38:
                  FUN_00b6825c(uStack_b4,uVar17,uStack_ac,uVar12,uStack_a4,uStack_a0,uStack_9c,
                               uStack_98,&uStack_120,1);
                  uStack_5c._0_2_ = CONCAT11(1,(undefined1)uStack_5c);
                  fVar35 = uStack_120._4_4_;
                }
                else {
                  fVar35 = uStack_120._4_4_;
                }
              }
              else if (uStack_5c._1_1_ == '\0') goto LAB_00b77a38;
            }
            fStack_144 = fStack_d0;
            fStack_c0 = fStack_d0;
            uStack_b8 = CONCAT31(uStack_b8._1_3_,uStack_120._1_1_);
            uStack_bc._0_3_ = CONCAT12(1,(ushort)uStack_bc);
            uStack_bc = CONCAT13(uStack_120._0_1_,(undefined3)uStack_bc);
            uStack_94 = CONCAT44(fVar43,fVar42);
            uStack_8c = CONCAT44(fStack_d0,fVar35);
            uStack_84 = uStack_bc;
            uStack_80 = uStack_120._1_1_;
            fStack_150 = fVar42;
            fStack_14c = fVar43;
            fStack_148 = fVar35;
            fStack_cc = fVar42;
            fStack_c8 = fVar43;
            fStack_c4 = fVar35;
            FUN_00b76644(fVar41 + fVar37 * fVar16,&uStack_120);
            FUN_00b76860(&uStack_120);
          } while (iVar31 != iVar11 * 0xe + -0xe);
        }
      }
      else {
        uStack_120._0_2_ = CONCAT11(2,uStack_120._0_1_);
        if ((int)(unaff_r9 + 1) < iVar11) {
          iVar31 = unaff_r9 * 0xe;
          fVar40 = 0.25;
          fVar36 = DAT_00b77874;
          fVar39 = DAT_00b77878;
          do {
            iVar22 = *(int *)(param_2 + 2);
            pfVar26 = (float *)(iVar22 + iVar31);
            iVar13 = iVar22 + iVar31;
            iVar31 = iVar31 + 0xe;
            fVar16 = *(float *)(iVar22 + iVar31);
            iVar22 = iVar22 + iVar31;
            fVar43 = fVar41 + fVar37 * *pfVar26;
            fVar34 = (float)VectorUnsignedToFloat
                                      ((uint)*(byte *)(iVar22 + 0xd),(byte)(in_fpscr >> 0x15) & 3);
            fVar42 = (float)dVar45 + fVar37 * *(float *)(iVar13 + 4);
            fVar35 = (float)VectorUnsignedToFloat
                                      ((uint)*(ushort *)(iVar22 + 10),(byte)(in_fpscr >> 0x15) & 3);
            fVar38 = *(float *)(iVar22 + 4) + fVar16 + fVar24;
            fVar35 = fVar35 * fVar40 * fVar37;
            uVar25 = ((uint)fVar38 ^ (uint)fVar38 >> 0x10) * 0x45d9f3b;
            uVar25 = (uVar25 ^ uVar25 >> 0x10) * 0x45d9f3b;
            uStack_120 = CONCAT44(fVar35,(undefined4)uStack_120);
            in_fpscr = in_fpscr & 0xfffffff | (uint)(fVar34 / fVar36 < fVar39) << 0x1f;
            uStack_f4 = (&DAT_013aea6c)[((uVar25 ^ uVar25 >> 0x10) & 3) * 3];
            bVar33 = SUB41(in_fpscr >> 0x1f,0);
            uVar23 = uStack_f4;
            if (bVar33) {
              uVar23 = 1;
            }
            uVar18 = (undefined1)uVar23;
            if (!bVar33) {
              uVar18 = 0;
            }
            uStack_f0 = CONCAT31(uStack_f0._1_3_,uVar18);
            if (uStack_bc._2_1_ == '\x02') {
              if ((uStack_5c & 0xff) == 0) {
                FUN_00b6825c(uStack_7c,uVar17,uStack_74,uVar12,uStack_6c,uStack_68,uStack_64,
                             uStack_60,&uStack_120);
                bVar33 = uStack_5c._1_1_ == '\0';
                uStack_5c = CONCAT31(uStack_5c._1_3_,1);
                if ((bVar33) && (uStack_bc._2_1_ == '\x02')) goto LAB_00b77734;
                fVar35 = uStack_120._4_4_;
              }
              else if (uStack_5c._1_1_ == '\0') {
LAB_00b77734:
                FUN_00b6825c(uStack_b4,uVar17,uStack_ac,uVar12,uStack_a4,uStack_a0,uStack_9c,
                             uStack_98,&uStack_120,1);
                uStack_5c._0_2_ = CONCAT11(1,(undefined1)uStack_5c);
                fVar35 = uStack_120._4_4_;
              }
            }
            uStack_138._4_4_ = fStack_d0;
            fStack_c0 = fStack_d0;
            uStack_b8 = CONCAT31(uStack_b8._1_3_,uStack_120._1_1_);
            uStack_bc._0_3_ = CONCAT12(1,(ushort)uStack_bc);
            uStack_bc = CONCAT13(uStack_120._0_1_,(undefined3)uStack_bc);
            uStack_94 = CONCAT44(fVar42,fVar43);
            uStack_8c = CONCAT44(fStack_d0,fVar35);
            uStack_84 = uStack_bc;
            uStack_80 = uStack_120._1_1_;
            uStack_140._0_4_ = fVar43;
            uStack_140._4_4_ = fVar42;
            uStack_138._0_4_ = fVar35;
            fStack_cc = fVar43;
            fStack_c8 = fVar42;
            fStack_c4 = fVar35;
            FUN_00b76644(fVar41 + fVar37 * fVar16,&uStack_120);
          } while (iVar11 * 0xe + -0xe != iVar31);
        }
      }
      FUN_00b76860(&uStack_120);
      QRegion::~QRegion(aQStack_dc);
      return;
    case (char *)0x3:
      iVar11 = FUN_00b6618c();
      if (*(char *)(iVar11 + 8) != '\0') {
        uStack_110 = *(undefined4 *)(iVar11 + 4);
        uStack_120 = DAT_00b81fd8;
        uStack_118 = 0;
        uVar12 = FUN_00b5f574(param_2);
        QMessageLogger::debug
                  ((char *)&uStack_120,"renderMarker: pointCount=%d, mode=%d, color=%d",uVar12,
                   param_3);
      }
      dVar45 = *(double *)(puVar27 + 0x1e);
      fVar41 = (float)*(double *)(puVar27 + 0x1c);
      fVar37 = (float)puVar27[0xe];
      iVar11 = FUN_00b5f574(param_2,param_2,param_3,0);
      bVar33 = param_3 == 0;
      uStack_b4 = 0;
      uStack_b0 = 0;
      uStack_5c = 0;
      fStack_58 = 0.0;
      if (bVar33) {
        unaff_r9 = iVar11 - 3;
      }
      uStack_104 = 0;
      uStack_120 = 0x3f80000000000000;
      uStack_10c = 0;
      uStack_ec = 0;
      uStack_e4 = 0;
      uStack_108 = 0;
      uStack_fc = 0xff000000;
      uStack_f8 = 0;
      uStack_f4 = 0;
      if (!bVar33) {
        unaff_r9 = 0;
      }
      uStack_f0 = 1;
      if (bVar33) {
        unaff_r9 = unaff_r9 & ~((int)unaff_r9 >> 0x1f);
      }
      QRegion::QRegion(aQStack_dc);
      fStack_c0 = 0.0;
      uStack_78 = (undefined2)uStack_b0;
      uStack_76 = (undefined2)((uint)uStack_b0 >> 0x10);
      uStack_d4 = 0;
      uStack_bc = (uint)(ushort)uStack_bc;
      uStack_b8 = uStack_b8 & 0xffffff00;
      uStack_84 = (uint)(ushort)uStack_84;
      uStack_80 = 0;
      fStack_d0 = (float)DAT_00b77348;
      fStack_cc = (float)((ulonglong)DAT_00b77348 >> 0x20);
      fStack_c8 = (float)DAT_00b77350;
      fStack_c4 = (float)((ulonglong)DAT_00b77350 >> 0x20);
      uStack_94 = DAT_00b77358;
      uStack_8c = DAT_00b77360;
      uStack_a4 = uStack_b4;
      uStack_a0 = uStack_b0;
      uStack_7c = uStack_b4;
      uStack_6c = uStack_b4;
      uStack_68 = uStack_b0;
      uStack_108 = QImage::constBits();
      uVar12 = QImage::bytesPerLine();
      uStack_104 = CONCAT44(uStack_104._4_4_,uVar12);
      uVar12 = QImage::depth();
      fStack_15c = (float)puVar27[0x25];
      iStack_158 = puVar27[0x26];
      pcStack_154 = (char *)puVar27[0x27];
      uStack_104 = CONCAT44(uVar12,(undefined4)uStack_104);
      fVar24 = (float)puVar27[0x24];
      iVar31 = QRegion::isEmpty();
      if (iVar31 == 0) {
        QRegion::operator=(aQStack_dc,(QRegion *)(puVar27 + 0x28));
      }
      else {
        uStack_138._0_4_ = fStack_15c;
        uStack_140._4_4_ = (float)(iStack_158 + 1);
        uStack_138._4_4_ = (float)((int)pcStack_154 + 1);
        auVar7._4_4_ = uStack_140._4_4_;
        auVar7._0_4_ = fVar24;
        auVar7._8_4_ = fStack_15c;
        auVar7._12_4_ = uStack_138._4_4_;
        auVar44 = VectorSignedToFloat(auVar7,8);
        uStack_ec = auVar44._0_8_;
        uStack_e4 = auVar44._8_8_;
        uStack_140._0_4_ = fVar24;
      }
      uStack_fc = FUN_0014cea0(puVar27 + 6,*(undefined4 *)param_2,*(undefined4 *)((int)param_2 + 4),
                               *(undefined4 *)(param_2 + 1));
      fVar24 = DAT_00b77368;
      bVar33 = param_3 == 1;
      fVar36 = extraout_s15_02;
      if (bVar33) {
        fVar36 = *(float *)(param_2 + 4);
      }
      if (bVar33) {
        fVar36 = fVar36 * (float)puVar27[0xe];
      }
      uStack_f8 = CONCAT22(uStack_f8._2_2_,
                           (ushort)(uStack_fc >> 8) & 0xf800 | (ushort)(uStack_fc >> 5) & 0x7e0 |
                           (ushort)((uStack_fc << 0x18) >> 0x1b));
      if (bVar33) {
        fStack_d0 = fVar36;
      }
      if ((int)(unaff_r9 + 2) < iVar11) {
        iVar31 = unaff_r9 * 0xe;
        fVar36 = DAT_00b7736c;
        fVar39 = DAT_00b77370;
        do {
          iVar20 = *(int *)(param_2 + 2);
          iVar22 = iVar31 + 0x1c;
          iVar13 = iVar20 + iVar31;
          iVar32 = iVar20 + iVar22;
          pfVar26 = (float *)(iVar20 + iVar31);
          iVar31 = iVar31 + 0xe;
          fVar40 = *(float *)(iVar20 + iVar22);
          uStack_130._4_4_ = *(float *)(iVar32 + 4);
          uVar25 = *(uint *)(iVar32 + 8);
          fVar35 = *(float *)(iVar20 + iVar31);
          uStack_128 = (undefined2)uVar25;
          uStack_126 = (undefined2)(uVar25 >> 0x10);
          fVar34 = fVar40 + uStack_130._4_4_ + fVar24;
          uStack_124 = (undefined1)*(undefined2 *)(iVar32 + 0xc);
          bStack_123 = (byte)((ushort)*(undefined2 *)(iVar32 + 0xc) >> 8);
          fVar16 = (float)VectorUnsignedToFloat(uVar25 & 0xffff,(byte)(in_fpscr >> 0x15) & 3);
          fVar16 = fVar16 * 0.25;
          uVar21 = ((uint)fVar34 ^ (uint)fVar34 >> 0x10) * 0x45d9f3b;
          uVar25 = in_fpscr & 0xfffffff;
          uVar19 = uVar25 | (uint)(fVar16 < 10.0) << 0x1f | (uint)(fVar16 == 10.0) << 0x1e;
          in_fpscr = uVar19 | (uint)NAN(fVar16) << 0x1c;
          uVar21 = (uVar21 ^ uVar21 >> 0x10) * 0x45d9f3b;
          bVar1 = (byte)(uVar19 >> 0x18);
          uStack_f4 = (&DAT_013aea6c)[((uVar21 ^ uVar21 >> 0x10) & 3) * 3];
          if ((bool)(bVar1 >> 6 & 1) || bVar1 >> 7 != ((byte)(in_fpscr >> 0x1c) & 1)) {
            fVar16 = (float)VectorUnsignedToFloat((uint)bStack_123,(byte)(in_fpscr >> 0x15) & 3);
            in_fpscr = uVar25 | (uint)(fVar16 / fVar36 < fVar39) << 0x1f;
            if (SUB41(in_fpscr >> 0x1f,0)) {
              uVar18 = 1;
            }
            else {
              uVar18 = 0;
            }
          }
          else {
            uVar18 = 1;
          }
          fVar16 = (float)VectorUnsignedToFloat
                                    ((uint)*(ushort *)(iVar32 + 10),(byte)(in_fpscr >> 0x15) & 3);
          uStack_f0 = CONCAT31(uStack_f0._1_3_,uVar18);
          fVar34 = fVar41 + *pfVar26 * fVar37;
          fVar38 = (float)dVar45 + *(float *)(iVar13 + 4) * fVar37;
          fVar16 = fVar16 * 0.25 * fVar37;
          uStack_120 = CONCAT44(fVar16,(undefined4)uStack_120);
          uStack_130._0_4_ = fVar40;
          if (uStack_bc._2_1_ == '\x02') {
            uVar12 = (undefined4)((ulonglong)dVar45 >> 0x20);
            if ((uStack_5c & 0xff) == 0) {
              FUN_00b6825c(uStack_7c,uVar17,uStack_74,uVar12,uStack_6c,uStack_68,uStack_64,uStack_60
                           ,&uStack_120);
              bVar33 = uStack_5c._1_1_ == '\0';
              uStack_5c = CONCAT31(uStack_5c._1_3_,1);
              if ((bVar33) && (uStack_bc._2_1_ == '\x02')) {
LAB_00b77300:
                FUN_00b6825c(uStack_b4,uVar17,uStack_ac,uVar12,uStack_a4,uStack_a0,uStack_9c,
                             uStack_98,&uStack_120,1);
                uStack_5c._0_2_ = CONCAT11(1,(undefined1)uStack_5c);
                fVar16 = uStack_120._4_4_;
              }
              else {
                fVar16 = uStack_120._4_4_;
              }
            }
            else if (uStack_5c._1_1_ == '\0') goto LAB_00b77300;
          }
          fStack_144 = fStack_d0;
          fStack_c0 = fStack_d0;
          uStack_b8 = CONCAT31(uStack_b8._1_3_,uStack_120._1_1_);
          uStack_bc._0_3_ = CONCAT12(1,(ushort)uStack_bc);
          uStack_bc = CONCAT13(uStack_120._0_1_,(undefined3)uStack_bc);
          uStack_94 = CONCAT44(fVar38,fVar34);
          uStack_8c = CONCAT44(fStack_d0,fVar16);
          uStack_84 = uStack_bc;
          uStack_80 = uStack_120._1_1_;
          fStack_150 = fVar34;
          fStack_14c = fVar38;
          fStack_148 = fVar16;
          fStack_cc = fVar34;
          fStack_c8 = fVar38;
          fStack_c4 = fVar16;
          FUN_00b76644(fVar41 + fVar35 * fVar37,&uStack_120);
          FUN_00b76644(fVar41 + fVar40 * fVar37,&uStack_120);
        } while (iVar31 != iVar11 * 0xe + -0x1c);
      }
      FUN_00b76860(&uStack_120);
      QRegion::~QRegion(aQStack_dc);
      return;
    case (char *)0x6:
      iVar11 = FUN_00b6618c();
      if (*(char *)(iVar11 + 8) != '\0') {
        uStack_110 = *(undefined4 *)(iVar11 + 4);
        uStack_120 = DAT_00b81fd8;
        uStack_118 = 0;
        uVar17 = FUN_00b5f574(param_2);
        QMessageLogger::debug
                  ((char *)&uStack_120,"renderEraserSolid: pointCount=%d, mode=%d, color=%d",uVar17,
                   param_3);
      }
      puVar14 = (undefined2 *)puVar27[0xc];
      if (puVar14 == (undefined2 *)0x0) {
        puVar14 = (undefined2 *)operator_new(200);
        memset(puVar14,0,200);
        *puVar14 = 0;
        *(undefined4 *)(puVar14 + 2) = 0x3f800000;
        *(undefined1 *)(puVar14 + 10) = 0;
        *(undefined4 *)(puVar14 + 0xc) = 0;
        *(undefined8 *)(puVar14 + 0xe) = 0;
        *(undefined4 *)(puVar14 + 0x16) = 0;
        *(undefined4 *)(puVar14 + 0x18) = 0;
        *(undefined4 *)(puVar14 + 0x12) = 0xff000000;
        *(undefined8 *)(puVar14 + 0x1a) = 0;
        *(undefined8 *)(puVar14 + 0x1e) = 0;
        QRegion::QRegion((QRegion *)(puVar14 + 0x22));
        pvVar29 = (void *)puVar27[0xc];
        puVar27[0xc] = puVar14;
        uVar10 = DAT_00b81fc0;
        uVar9 = DAT_00b81fb8;
        *(undefined4 *)(puVar14 + 0x26) = 0;
        puVar14[0x62] = 0;
        *(undefined8 *)(puVar14 + 0x52) = 0;
        *(undefined8 *)(puVar14 + 0x56) = 0;
        *(undefined8 *)(puVar14 + 0x5a) = 0;
        *(undefined8 *)(puVar14 + 0x5e) = 0;
        *(undefined8 *)(puVar14 + 0x28) = uVar9;
        *(undefined8 *)(puVar14 + 0x2c) = uVar10;
        *(undefined4 *)(puVar14 + 0x30) = 0;
        puVar14[0x33] = 0;
        *(undefined1 *)(puVar14 + 0x34) = 0;
        uVar10 = DAT_00b81fd0;
        uVar9 = DAT_00b81fc8;
        *(undefined8 *)(puVar14 + 0x36) = 0;
        *(undefined8 *)(puVar14 + 0x3a) = 0;
        *(undefined8 *)(puVar14 + 0x3e) = 0;
        *(undefined8 *)(puVar14 + 0x42) = 0;
        *(undefined8 *)(puVar14 + 0x46) = uVar9;
        *(undefined8 *)(puVar14 + 0x4a) = uVar10;
        puVar14[0x4f] = 0;
        *(undefined1 *)(puVar14 + 0x50) = 0;
        if (pvVar29 != (void *)0x0) {
          FUN_00b780c0(pvVar29);
          QRegion::~QRegion((QRegion *)((int)pvVar29 + 0x44));
          operator_delete(pvVar29,200);
          puVar14 = (undefined2 *)puVar27[0xc];
        }
        uVar17 = QImage::constBits();
        *(undefined4 *)(puVar14 + 0xc) = uVar17;
        uVar17 = QImage::bytesPerLine();
        *(undefined4 *)(puVar14 + 0xe) = uVar17;
        uVar17 = QImage::depth();
        uVar12 = puVar27[0x25];
        *(undefined4 *)(puVar14 + 0x10) = uVar17;
        uVar17 = puVar27[0x24];
        iVar13 = puVar27[0x26];
        iVar31 = puVar27[0x27];
        iVar11 = QRegion::isEmpty();
        if (iVar11 == 0) {
          QRegion::operator=((QRegion *)(puVar14 + 0x22),(QRegion *)(puVar27 + 0x28));
        }
        else {
          auVar4._4_4_ = iVar13 + 1;
          auVar4._0_4_ = uVar17;
          auVar4._8_4_ = uVar12;
          auVar4._12_4_ = iVar31 + 1;
          auVar44 = VectorSignedToFloat(auVar4,8);
          *(longlong *)(puVar14 + 0x1a) = auVar44._0_8_;
          *(longlong *)(puVar14 + 0x1e) = auVar44._8_8_;
        }
        puVar14 = (undefined2 *)puVar27[0xc];
      }
      *puVar14 = 0x201;
      *(undefined4 *)(puVar14 + 0x12) = puVar27[4];
      puVar14[0x14] = *(undefined2 *)(puVar27 + 5);
      iVar11 = QImage::isNull();
      if (iVar11 == 0) {
        uVar17 = QImage::constBits();
        *(undefined4 *)(puVar27[0xc] + 0x2c) = uVar17;
        uVar17 = QImage::bytesPerLine();
        iVar11 = puVar27[0xc];
        *(undefined4 *)(iVar11 + 0x30) = uVar17;
      }
      else {
        iVar11 = puVar27[0xc];
        *(undefined4 *)(iVar11 + 0x2c) = 0;
        *(undefined4 *)(iVar11 + 0x30) = 0;
      }
      FUN_00b78258(iVar11,param_2,param_3,puVar27 + 0x10);
      return;
    case (char *)0x7:
      iVar11 = FUN_00b6618c();
      if (*(char *)(iVar11 + 8) != '\0') {
        uStack_110 = *(undefined4 *)(iVar11 + 4);
        uStack_120 = DAT_00b81fd8;
        uStack_118 = 0;
        uVar17 = FUN_00b5f574(param_2);
        QMessageLogger::debug
                  ((char *)&uStack_120,"renderSharpPencil: pointCount=%d, mode=%d, color=%d",uVar17,
                   param_3);
      }
      fVar37 = (float)puVar27[0xe];
      fVar41 = (float)*(double *)(puVar27 + 0x1c);
      iVar11 = FUN_00b5f574(param_2);
      uStack_b4 = 0;
      uStack_b0 = 0;
      uStack_5c = 0;
      fStack_58 = 0.0;
      bVar33 = param_3 == 0;
      uStack_104 = 0;
      if (bVar33) {
        unaff_r8 = iVar11 - 2;
      }
      uStack_ec = 0;
      uStack_e4 = 0;
      uStack_120 = 0x3f80000000000000;
      uStack_fc = 0xff000000;
      uStack_10c = 0;
      if (!bVar33) {
        unaff_r8 = 0;
      }
      uStack_108 = 0;
      uStack_f8 = 0;
      uStack_f4 = 0;
      uStack_f0 = 1;
      if (bVar33) {
        unaff_r8 = unaff_r8 & ~((int)unaff_r8 >> 0x1f);
      }
      QRegion::QRegion(aQStack_dc);
      uStack_d4 = 0;
      uStack_bc = (uint)(ushort)uStack_bc;
      uStack_b8 = uStack_b8 & 0xffffff00;
      uStack_84 = (uint)(ushort)uStack_84;
      fStack_c0 = 0.0;
      uStack_80 = 0;
      fStack_d0 = (float)DAT_00b81500;
      fStack_cc = (float)((ulonglong)DAT_00b81500 >> 0x20);
      fStack_c8 = (float)DAT_00b81508;
      fStack_c4 = (float)((ulonglong)DAT_00b81508 >> 0x20);
      uStack_78 = (undefined2)uStack_b0;
      uStack_76 = (undefined2)((uint)uStack_b0 >> 0x10);
      uStack_94 = DAT_00b81510;
      uStack_8c = DAT_00b81518;
      uStack_a4 = uStack_b4;
      uStack_a0 = uStack_b0;
      uStack_7c = uStack_b4;
      uStack_6c = uStack_b4;
      uStack_68 = uStack_b0;
      uStack_108 = QImage::constBits();
      uVar17 = QImage::bytesPerLine();
      uStack_104 = CONCAT44(uStack_104._4_4_,uVar17);
      uVar17 = QImage::depth();
      uVar23 = puVar27[0x24];
      uVar12 = puVar27[0x25];
      iVar13 = puVar27[0x27];
      uStack_104 = CONCAT44(uVar17,(undefined4)uStack_104);
      iVar22 = puVar27[0x26];
      iVar31 = QRegion::isEmpty();
      if (iVar31 == 0) {
        QRegion::operator=(aQStack_dc,(QRegion *)(puVar27 + 0x28));
      }
      else {
        auVar5._4_4_ = iVar22 + 1;
        auVar5._0_4_ = uVar23;
        auVar5._8_4_ = uVar12;
        auVar5._12_4_ = iVar13 + 1;
        auVar44 = VectorSignedToFloat(auVar5,8);
        uStack_ec = auVar44._0_8_;
        uStack_e4 = auVar44._8_8_;
      }
      FUN_00b742c8(puVar27,&uStack_120,param_2,param_3);
      fVar24 = DAT_00b81520;
      uStack_120._0_2_ = CONCAT11(2,uStack_120._0_1_);
      if ((int)(unaff_r8 + 1) < iVar11) {
        if (param_3 == 1) {
          iVar31 = unaff_r8 * 0xe;
          do {
            iVar13 = *(int *)(param_2 + 2);
            pfVar26 = (float *)(iVar13 + iVar31);
            iVar31 = iVar31 + 0xe;
            fVar36 = *(float *)(iVar13 + iVar31);
            fVar39 = (float)VectorUnsignedToFloat
                                      ((uint)*(ushort *)(iVar13 + iVar31 + 10),
                                       (byte)(in_fpscr >> 0x15) & 3);
            fVar40 = fVar36 + *(float *)(iVar13 + iVar31 + 4) + fVar24;
            uVar25 = ((uint)fVar40 ^ (uint)fVar40 >> 0x10) * 0x45d9f3b;
            uVar25 = (uVar25 ^ uVar25 >> 0x10) * 0x45d9f3b;
            uStack_120 = CONCAT44(fVar39 * 0.25 * fVar37,(undefined4)uStack_120);
            uStack_f4 = *(undefined4 *)(&DAT_013aeafc + ((uVar25 ^ uVar25 >> 0x10) & 3) * 0xc);
            FUN_00b76304(fVar41 + fVar37 * *pfVar26,&uStack_120);
            FUN_00b76644(fVar41 + fVar37 * fVar36,&uStack_120);
            FUN_00b76860(&uStack_120);
          } while (iVar31 != iVar11 * 0xe + -0xe);
        }
        else {
          iVar31 = unaff_r8 * 0xe;
          do {
            iVar13 = *(int *)(param_2 + 2);
            pfVar26 = (float *)(iVar13 + iVar31);
            iVar31 = iVar31 + 0xe;
            fVar36 = *(float *)(iVar13 + iVar31);
            fVar39 = (float)VectorUnsignedToFloat
                                      ((uint)*(ushort *)(iVar13 + iVar31 + 10),
                                       (byte)(in_fpscr >> 0x15) & 3);
            fVar40 = *(float *)(iVar13 + iVar31 + 4) + fVar36 + fVar24;
            uVar25 = ((uint)fVar40 ^ (uint)fVar40 >> 0x10) * 0x45d9f3b;
            uVar25 = (uVar25 ^ uVar25 >> 0x10) * 0x45d9f3b;
            uStack_120 = CONCAT44(fVar39 * 0.25 * fVar37,(undefined4)uStack_120);
            uStack_f4 = *(undefined4 *)(&DAT_013aeafc + ((uVar25 ^ uVar25 >> 0x10) & 3) * 0xc);
            FUN_00b76304(fVar41 + fVar37 * *pfVar26,&uStack_120);
            FUN_00b76644(fVar41 + fVar37 * fVar36,&uStack_120);
          } while (iVar11 * 0xe + -0xe != iVar31);
        }
      }
      FUN_00b76860(&uStack_120);
      QRegion::~QRegion(aQStack_dc);
      return;
    case (char *)0xc:
      iVar11 = FUN_00b6618c();
      if (*(char *)(iVar11 + 8) != '\0') {
        uStack_110 = *(undefined4 *)(iVar11 + 4);
        uStack_120 = DAT_00b81fd8;
        uStack_118 = 0;
        uVar17 = FUN_00b5f574(param_2);
        QMessageLogger::debug
                  ((char *)&uStack_120,"renderPaintBrush_v2: pointCount=%d, mode=%d, color=%d",
                   uVar17,param_3);
      }
      iVar11 = puVar27[10];
      if (iVar11 == 0) {
        puVar14 = (undefined2 *)operator_new(0x100);
        memset(puVar14,0,0x100);
        FUN_00b745e0(puVar14);
        pvVar29 = (void *)puVar27[10];
        puVar27[10] = puVar14;
        if (pvVar29 != (void *)0x0) {
          FUN_00b7f218(pvVar29);
          QRegion::~QRegion((QRegion *)((int)pvVar29 + 0x3c));
          operator_delete(pvVar29,0x100);
          puVar14 = (undefined2 *)puVar27[10];
        }
        *puVar14 = 0x201;
        uVar17 = QImage::constBits();
        *(undefined4 *)(puVar14 + 0xc) = uVar17;
        uVar17 = QImage::bytesPerLine();
        *(undefined4 *)(puVar14 + 0xe) = uVar17;
        uVar17 = QImage::depth();
        uVar12 = puVar27[0x25];
        *(undefined4 *)(puVar14 + 0x10) = uVar17;
        uVar17 = puVar27[0x24];
        iVar13 = puVar27[0x26];
        iVar31 = puVar27[0x27];
        iVar11 = QRegion::isEmpty();
        if (iVar11 == 0) {
          QRegion::operator=((QRegion *)(puVar14 + 0x1e),(QRegion *)(puVar27 + 0x28));
        }
        else {
          auVar3._4_4_ = iVar13 + 1;
          auVar3._0_4_ = uVar17;
          auVar3._8_4_ = uVar12;
          auVar3._12_4_ = iVar31 + 1;
          auVar44 = VectorSignedToFloat(auVar3,8);
          *(longlong *)(puVar14 + 0x16) = auVar44._0_8_;
          *(longlong *)(puVar14 + 0x1a) = auVar44._8_8_;
        }
        iVar11 = puVar27[10];
      }
      fVar37 = (float)puVar27[0xe];
      uVar23 = *(undefined4 *)(param_2 + 1);
      uVar17 = *(undefined4 *)param_2;
      uVar12 = *(undefined4 *)((int)param_2 + 4);
      *(float *)(iVar11 + 0x44) = DAT_00b8153c / fVar37;
      *(float *)(iVar11 + 0x48) = 1.5 / fVar37;
      uVar25 = FUN_0014cea0(puVar27 + 6,uVar17,uVar12,uVar23);
      *(uint *)(iVar11 + 0x24) = uVar25;
      bVar33 = param_3 == 1;
      fVar37 = extraout_s15_03;
      if (bVar33) {
        fVar37 = *(float *)(param_2 + 4);
      }
      fVar41 = extraout_s14;
      if (bVar33) {
        fVar41 = (float)puVar27[0xe];
      }
      if (bVar33) {
        fVar37 = fVar37 * fVar41;
      }
      *(ushort *)(iVar11 + 0x28) =
           (ushort)(uVar25 >> 8) & 0xf800 | (ushort)(uVar25 >> 5) & 0x7e0 |
           (ushort)((uVar25 << 0x18) >> 0x1b);
      uVar17 = puVar27[10];
      if (bVar33) {
        *(float *)(iVar11 + 0x50) = fVar37;
      }
      FUN_00b8078c(uVar17,param_2,param_3,puVar27 + 0x10);
      return;
    case (char *)0x10:
      iVar11 = FUN_00b6618c();
      if (*(char *)(iVar11 + 8) != '\0') {
        uStack_110 = *(undefined4 *)(iVar11 + 4);
        uStack_120 = DAT_00b81fd8;
        uStack_118 = 0;
        uVar17 = FUN_00b5f574(param_2);
        QMessageLogger::debug
                  ((char *)&uStack_120,"renderMarker_v2: pointCount=%d, mode=%d, color=%d",uVar17,
                   param_3);
      }
      iVar11 = puVar27[0xb];
      if (iVar11 == 0) {
        puVar14 = (undefined2 *)operator_new(0x100);
        memset(puVar14,0,0x100);
        FUN_00b745e0(puVar14);
        pvVar29 = (void *)puVar27[0xb];
        puVar27[0xb] = puVar14;
        if (pvVar29 != (void *)0x0) {
          FUN_00b7f218(pvVar29);
          QRegion::~QRegion((QRegion *)((int)pvVar29 + 0x3c));
          operator_delete(pvVar29,0x100);
          puVar14 = (undefined2 *)puVar27[0xb];
        }
        *puVar14 = 0x201;
        uVar17 = QImage::constBits();
        *(undefined4 *)(puVar14 + 0xc) = uVar17;
        uVar17 = QImage::bytesPerLine();
        *(undefined4 *)(puVar14 + 0xe) = uVar17;
        uVar17 = QImage::depth();
        uVar12 = puVar27[0x25];
        *(undefined4 *)(puVar14 + 0x10) = uVar17;
        uVar17 = puVar27[0x24];
        iVar13 = puVar27[0x26];
        iVar31 = puVar27[0x27];
        iVar11 = QRegion::isEmpty();
        if (iVar11 == 0) {
          QRegion::operator=((QRegion *)(puVar14 + 0x1e),(QRegion *)(puVar27 + 0x28));
        }
        else {
          auVar44._4_4_ = iVar13 + 1;
          auVar44._0_4_ = uVar17;
          auVar44._8_4_ = uVar12;
          auVar44._12_4_ = iVar31 + 1;
          auVar44 = VectorSignedToFloat(auVar44,8);
          *(longlong *)(puVar14 + 0x16) = auVar44._0_8_;
          *(longlong *)(puVar14 + 0x1a) = auVar44._8_8_;
        }
        iVar11 = puVar27[0xb];
      }
      fVar37 = (float)puVar27[0xe];
      uVar23 = *(undefined4 *)(param_2 + 1);
      uVar17 = *(undefined4 *)param_2;
      uVar12 = *(undefined4 *)((int)param_2 + 4);
      *(float *)(iVar11 + 0x44) = DAT_00b8153c / fVar37;
      *(float *)(iVar11 + 0x48) = 1.5 / fVar37;
      uVar25 = FUN_0014cea0(puVar27 + 6,uVar17,uVar12,uVar23);
      *(uint *)(iVar11 + 0x24) = uVar25;
      bVar33 = param_3 == 1;
      fVar37 = extraout_s15_04;
      if (bVar33) {
        fVar37 = *(float *)(param_2 + 4);
      }
      fVar41 = extraout_s14_00;
      if (bVar33) {
        fVar41 = (float)puVar27[0xe];
      }
      if (bVar33) {
        fVar37 = fVar37 * fVar41;
      }
      *(ushort *)(iVar11 + 0x28) =
           (ushort)(uVar25 >> 8) & 0xf800 | (ushort)(uVar25 >> 5) & 0x7e0 |
           (ushort)((uVar25 << 0x18) >> 0x1b);
      uVar17 = puVar27[0xb];
      if (bVar33) {
        *(float *)(iVar11 + 0x50) = fVar37;
      }
      FUN_00b80b50(uVar17,param_2,param_3,puVar27 + 0x10);
      return;
    }
switchD_00b80e74_caseD_4:
    iVar11 = FUN_00b6618c();
    if (*(char *)(iVar11 + 9) == '\0') {
      return;
    }
    uStack_110 = *(undefined4 *)(iVar11 + 4);
    uStack_120 = DAT_00b81fd8;
    uStack_118 = 0;
    QMessageLogger::warning();
    piVar15 = (int *)FUN_0012c8f4((QDebug *)&iStack_158,"unhandled tool:");
    fStack_14c = (float)*piVar15;
    *(int *)((int)fStack_14c + 0x14) = *(int *)((int)fStack_14c + 0x14) + 1;
    qt_QMetaEnum_debugOperator
              ((QDebug *)&uStack_140,0x10ab704011db5b8,(QMetaObject *)&fStack_14c,pcVar30);
    QDebug::~QDebug((QDebug *)&uStack_140);
    QDebug::~QDebug((QDebug *)&fStack_14c);
    QDebug::~QDebug((QDebug *)&iStack_158);
    return;
  }
  if (*(int *)((int)param_2 + 4) == 1) goto switchD_00b80e74_caseD_4;
  FUN_00b709f4();
  pQVar28 = (QPen *)*puVar27;
  if (pQVar28 == (QPen *)0x0) {
    return;
  }
  if (*(int *)((int)param_2 + 0x14) < 2) {
    return;
  }
  QPainter::setCompositionMode(pQVar28,0);
  piVar15 = *(int **)((int)param_2 + 0xc);
  iVar11 = *(int *)(param_2 + 2);
  iVar31 = *(int *)((int)param_2 + 0x14);
  if (piVar15 == (int *)0x0) {
    if (iVar31 < 3) {
      return;
    }
  }
  else {
    DataMemoryBarrier(0xb);
    do {
      bVar33 = (bool)hasExclusiveAccess(piVar15);
    } while (!bVar33);
    *piVar15 = *piVar15 + 1;
    DataMemoryBarrier(0xb);
    if (iVar31 < 3) goto LAB_00b81844;
  }
  fVar37 = DAT_00b810ac;
  pfVar26 = (float *)(iVar11 + 0x1c);
  iVar11 = 2;
  do {
    fVar36 = SUB84(in_d0,0);
    fVar24 = pfVar26[1];
    fVar41 = *pfVar26;
    uStack_138 = (double)fVar24;
    uStack_140 = (double)fVar41;
    dVar45 = (double)*(float *)((int)pfVar26 + -10);
    uStack_128 = SUB82(dVar45,0);
    uStack_126 = (undefined2)((ulonglong)dVar45 >> 0x10);
    uStack_124 = (undefined1)((ulonglong)dVar45 >> 0x20);
    bStack_123 = (byte)((ulonglong)dVar45 >> 0x28);
    uStack_122 = (undefined2)((ulonglong)dVar45 >> 0x30);
    uStack_130 = (double)*(float *)((int)pfVar26 + -0xe);
    QPen::QPen(aQStack_198);
    QPen::setCapStyle(aQStack_198,0x20);
    DataMemoryBarrier(0xb);
    if ((DAT_013aeb2c & 1) == 0) {
      iVar13 = __cxa_guard_acquire(&DAT_013aeb2c);
      if (iVar13 != 0) {
        uStack_120 = 0x10b285000000013;
        QString::fromUtf8((QString *)&fStack_14c,0x13,":/images/brush0.png");
        QImage::QImage((QImage *)&uStack_120,(QString *)&fStack_14c,(char *)0x0);
        QBitmap::fromImage(DAT_00b81534,(QImage *)&uStack_120,0);
        pcStack_154 = ":/images/brush1.png";
        iStack_158 = 0x13;
        QString::fromUtf8(aQStack_164,0x13,":/images/brush1.png");
        QImage::QImage((QImage *)&iStack_158,aQStack_164,(char *)0x0);
        QBitmap::fromImage(DAT_00b81528,(QImage *)&iStack_158,0);
        pcStack_16c = ":/images/brush2.png";
        uStack_170 = 0x13;
        QString::fromUtf8(aQStack_17c,0x13,":/images/brush2.png");
        QImage::QImage((QImage *)&uStack_170,aQStack_17c,(char *)0x0);
        QBitmap::fromImage(DAT_00b8152c,&uStack_170,0);
        pcStack_184 = ":/images/brush3.png";
        uStack_188 = 0x13;
        QString::fromUtf8(aQStack_194,0x13,":/images/brush3.png");
        QImage::QImage((QImage *)&uStack_188,aQStack_194,(char *)0x0);
        QBitmap::fromImage(DAT_00b81530,&uStack_188,0);
        __aeabi_atexit(DAT_00b81534,FUN_00b6d054,&DAT_0138d044);
        __cxa_guard_release(DAT_00b81538);
        QImage::~QImage((QImage *)&uStack_188);
        FUN_00088fa0(aQStack_194);
        QImage::~QImage((QImage *)&uStack_170);
        FUN_00088fa0(aQStack_17c);
        QImage::~QImage((QImage *)&iStack_158);
        FUN_00088fa0(aQStack_164);
        QImage::~QImage((QImage *)&uStack_120);
        FUN_00088fa0((QString *)&fStack_14c);
      }
    }
    fVar39 = (float)VectorUnsignedToFloat
                              ((uint)*(ushort *)(pfVar26 + 2),(byte)(in_fpscr >> 0x15) & 3);
    fVar39 = fVar39 * 0.25;
    uVar25 = in_fpscr & 0xfffffff | (uint)(fVar39 < 20.0) << 0x1f | (uint)(fVar39 == 20.0) << 0x1e;
    in_fpscr = uVar25 | (uint)NAN(fVar39) << 0x1c;
    bVar1 = (byte)(uVar25 >> 0x18);
    if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1)) {
      fVar41 = fVar41 + fVar24 + fVar37;
      uVar25 = ((uint)fVar41 ^ (uint)fVar41 >> 0x10) * 0x45d9f3b;
      uVar25 = (uVar25 ^ uVar25 >> 0x10) * 0x45d9f3b;
      QBrush::QBrush((QBrush *)&fStack_14c,
                     (QPixmap *)(((uVar25 ^ uVar25 >> 0x10) & 3) * 0xc + DAT_00b81534));
      memcpy(&uStack_120,DAT_00b81524,0x48);
      uStack_d8 = uStack_d8 & 0xfc00;
      fVar41 = (float)VectorUnsignedToFloat
                                ((uint)*(byte *)(pfVar26 + 3),(byte)(in_fpscr >> 0x15) & 3);
      fVar36 = SUB84((double)(((fVar41 + fVar41) * DAT_00b81540) / DAT_00b81544),0);
      QTransform::rotateRadians(fVar36,&uStack_120,2);
      QBrush::setTransform((QTransform *)&fStack_14c);
      QPen::setBrush((QBrush *)aQStack_198);
      QBrush::~QBrush((QBrush *)&fStack_14c);
    }
    if (*(int *)((int)param_2 + 4) == 2) {
      QColor::QColor((QColor *)&uStack_120,3);
      QPen::setColor((QColor *)aQStack_198);
    }
    fVar41 = (float)VectorUnsignedToFloat
                              ((uint)*(ushort *)((int)pfVar26 + 10),(byte)(in_fpscr >> 0x15) & 3);
    dVar45 = (double)VectorSignedToFloat((int)(fVar41 * 0.25),(byte)(in_fpscr >> 0x15) & 3);
    FUN_00b5f7fc(0x3f800000,param_2);
    in_d0 = (double)fVar36;
    in_fpscr = in_fpscr & 0xfffffff;
    if (dVar45 == in_d0 || dVar45 < in_d0 != (NAN(dVar45) || NAN(in_d0))) {
      in_d0 = dVar45;
    }
    QPen::setWidthF((double)CONCAT44(in_stack_fffffe14,in_stack_fffffe10));
    QPainter::setPen(pQVar28);
    QPainter::drawLines((QLineF *)pQVar28,(int)&uStack_140);
    iVar11 = iVar11 + 1;
    pfVar26 = (float *)((int)pfVar26 + 0xe);
    QPen::~QPen(aQStack_198);
  } while (iVar11 < iVar31);
  if (piVar15 == (int *)0x0) {
    return;
  }
LAB_00b81844:
  DataMemoryBarrier(0xb);
  do {
    iVar11 = *piVar15;
    bVar33 = (bool)hasExclusiveAccess(piVar15);
  } while (!bVar33);
  *piVar15 = iVar11 + -1;
  DataMemoryBarrier(0xb);
  if (iVar11 + -1 != 0) {
    return;
  }
  free(piVar15);
  return;
}

