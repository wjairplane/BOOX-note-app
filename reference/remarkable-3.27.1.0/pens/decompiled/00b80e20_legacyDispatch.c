
/* WARNING: Heritage AFTER dead removal. Example location: s1 : 0x00b772c8 */
/* WARNING: Restarted to delay deadcode elimination for space: register */

void FUN_00b80e20(undefined4 *param_1,undefined4 *param_2,int param_3)

{
  byte bVar1;
  undefined1 auVar2 [16];
  undefined1 auVar3 [16];
  undefined1 auVar4 [16];
  undefined1 auVar5 [16];
  undefined1 auVar6 [16];
  undefined1 auVar7 [16];
  undefined8 uVar8;
  undefined8 uVar9;
  undefined4 uVar10;
  int iVar11;
  int iVar12;
  undefined2 *puVar13;
  int *piVar14;
  float fVar15;
  float fVar16;
  undefined4 uVar17;
  float fVar18;
  undefined1 uVar19;
  uint uVar20;
  int iVar21;
  uint uVar22;
  int iVar23;
  undefined4 uVar24;
  float fVar25;
  uint uVar26;
  float *pfVar27;
  QPen *pQVar28;
  uint unaff_r8;
  void *pvVar29;
  uint unaff_r9;
  char *pcVar30;
  int iVar31;
  int iVar32;
  bool bVar33;
  uint in_fpscr;
  double in_d0;
  undefined8 in_d1;
  float fVar34;
  float fVar35;
  float extraout_s14;
  float extraout_s14_00;
  float extraout_s15;
  float extraout_s15_00;
  float fVar36;
  float fVar37;
  float fVar38;
  float extraout_s15_01;
  float extraout_s15_02;
  float fVar39;
  float fVar40;
  float fVar41;
  undefined1 auVar42 [16];
  double dVar43;
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
  undefined4 uStack_78;
  undefined4 uStack_74;
  undefined4 uStack_6c;
  undefined4 uStack_68;
  undefined4 uStack_64;
  undefined4 uStack_60;
  undefined4 uStack_5c;
  undefined4 uStack_58;
  
  pcVar30 = (char *)*param_2;
  if (pcVar30 != (char *)0x0) {
    uVar17 = (undefined4)((ulonglong)in_d0 >> 0x20);
    switch(pcVar30) {
    case (char *)0x1:
      iVar11 = FUN_00b6618c();
      if (*(char *)(iVar11 + 8) != '\0') {
        uStack_110 = *(undefined4 *)(iVar11 + 4);
        uStack_120 = DAT_00b81fd8;
        uStack_118 = 0;
        uVar10 = FUN_00b5f574(param_2);
        QMessageLogger::debug
                  ((char *)&uStack_120,"renderPencil: pointCount=%d, mode=%d, color=%d",uVar10,
                   param_3);
      }
      dVar43 = *(double *)(param_1 + 0x1e);
      fVar18 = (float)*(double *)(param_1 + 0x1c);
      fVar39 = (float)param_1[0xe];
      iVar11 = FUN_00b5f574(param_2,param_2,param_3,0);
      bVar33 = param_3 == 0;
      uStack_b4 = 0;
      uStack_b0 = 0;
      uStack_5c = 0;
      uStack_58 = 0;
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
      uStack_78 = uStack_b0;
      uStack_6c = uStack_b4;
      uStack_68 = uStack_b0;
      uStack_108 = QImage::constBits();
      uVar10 = QImage::bytesPerLine();
      uStack_104 = CONCAT44(uStack_104._4_4_,uVar10);
      uVar10 = QImage::depth();
      fStack_15c = (float)param_1[0x25];
      pcStack_154 = (char *)param_1[0x26];
      iStack_158 = param_1[0x27];
      uStack_104 = CONCAT44(uVar10,(undefined4)uStack_104);
      fVar25 = (float)param_1[0x24];
      iVar31 = QRegion::isEmpty();
      if (iVar31 == 0) {
        QRegion::operator=(aQStack_dc,(QRegion *)(param_1 + 0x28));
      }
      else {
        uStack_138._0_4_ = fStack_15c;
        uStack_140._4_4_ = (float)((int)pcStack_154 + 1);
        uStack_138._4_4_ = (float)(iStack_158 + 1);
        auVar5._4_4_ = uStack_140._4_4_;
        auVar5._0_4_ = fVar25;
        auVar5._8_4_ = fStack_15c;
        auVar5._12_4_ = uStack_138._4_4_;
        auVar42 = VectorSignedToFloat(auVar5,8);
        uStack_ec = auVar42._0_8_;
        uStack_e4 = auVar42._8_8_;
        uStack_140._0_4_ = fVar25;
      }
      uStack_fc = FUN_0014cea0(param_1 + 6,*param_2,param_2[1],param_2[2]);
      fVar16 = DAT_00b76ea4;
      fVar25 = DAT_00b76ea0;
      bVar33 = param_3 == 1;
      fVar37 = extraout_s15;
      if (bVar33) {
        fVar37 = (float)param_2[8];
      }
      if (bVar33) {
        fVar37 = fVar37 * (float)param_1[0xe];
      }
      uStack_f8 = CONCAT22(uStack_f8._2_2_,
                           (ushort)(uStack_fc >> 8) & 0xf800 | (ushort)(uStack_fc >> 5) & 0x7e0 |
                           (ushort)((uStack_fc << 0x18) >> 0x1b));
      if (bVar33) {
        fStack_d0 = fVar37;
      }
      if ((int)(unaff_r9 + 2) < iVar11) {
        iVar31 = unaff_r9 * 0xe;
        fVar38 = 0.25;
        fVar37 = DAT_00b76ea8;
        do {
          iVar23 = param_2[4];
          iVar21 = iVar31 + 0x1c;
          pfVar27 = (float *)(iVar23 + iVar31);
          iVar12 = iVar23 + iVar31;
          iVar31 = iVar31 + 0xe;
          iVar32 = iVar23 + iVar21;
          fVar35 = *(float *)(iVar23 + iVar21);
          uStack_130._4_4_ = *(float *)(iVar32 + 4);
          fVar15 = *(float *)(iVar23 + iVar31);
          uStack_128 = (undefined2)*(undefined4 *)(iVar32 + 8);
          uStack_126 = (undefined2)((uint)*(undefined4 *)(iVar32 + 8) >> 0x10);
          uStack_124 = (undefined1)*(undefined2 *)(iVar32 + 0xc);
          bStack_123 = (byte)((ushort)*(undefined2 *)(iVar32 + 0xc) >> 8);
          fVar34 = (float)VectorUnsignedToFloat((uint)bStack_123,(byte)(in_fpscr >> 0x15) & 3);
          fVar36 = fVar35 + uStack_130._4_4_ + fVar25;
          uVar26 = ((uint)fVar36 ^ (uint)fVar36 >> 0x10) * 0x45d9f3b;
          uVar26 = (uVar26 ^ uVar26 >> 0x10) * 0x45d9f3b;
          uVar20 = (uVar26 ^ uVar26 >> 0x10) & 3;
          uVar26 = in_fpscr & 0xfffffff;
          in_fpscr = uVar26 | (uint)(fVar34 / fVar16 < 0.75) << 0x1f;
          if (SUB41(in_fpscr >> 0x1f,0)) {
            uStack_f4 = *(undefined4 *)(&DAT_013aeacc + uVar20 * 0xc);
          }
          else {
            in_fpscr = uVar26 | (uint)(fVar34 / fVar16 < fVar37) << 0x1f;
            iVar23 = uVar20 * 0xc;
            if (SUB41(in_fpscr >> 0x1f,0)) {
              uStack_f4 = *(undefined4 *)(&DAT_013aea9c + iVar23);
            }
            else {
              uStack_f4 = *(undefined4 *)(&DAT_013aeafc + iVar23);
            }
          }
          fVar34 = (float)VectorUnsignedToFloat
                                    ((uint)*(ushort *)(iVar32 + 10),(byte)(in_fpscr >> 0x15) & 3);
          fVar36 = fVar18 + *pfVar27 * fVar39;
          fVar40 = (float)dVar43 + *(float *)(iVar12 + 4) * fVar39;
          fVar34 = fVar34 * fVar38 * fVar39;
          uStack_120 = CONCAT44(fVar34,(undefined4)uStack_120);
          uStack_130._0_4_ = fVar35;
          if (uStack_bc._2_1_ == '\x02') {
            uVar10 = (undefined4)((ulonglong)dVar43 >> 0x20);
            if ((uStack_5c & 0xff) == 0) {
              FUN_00b6825c(uStack_7c,uVar17,uStack_74,uVar10,uStack_6c,uStack_68,uStack_64,uStack_60
                           ,&uStack_120);
              bVar33 = uStack_5c._1_1_ == '\0';
              uStack_5c = CONCAT31(uStack_5c._1_3_,1);
              if ((bVar33) && (uStack_bc._2_1_ == '\x02')) {
LAB_00b76e14:
                FUN_00b6825c(uStack_b4,uVar17,uStack_ac,uVar10,uStack_a4,uStack_a0,uStack_9c,
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
          uStack_94 = CONCAT44(fVar40,fVar36);
          uStack_8c = CONCAT44(fStack_d0,fVar34);
          uStack_84 = uStack_bc;
          uStack_80 = uStack_120._1_1_;
          fStack_150 = fVar36;
          fStack_14c = fVar40;
          fStack_148 = fVar34;
          fStack_cc = fVar36;
          fStack_c8 = fVar40;
          fStack_c4 = fVar34;
          FUN_00b76644(fVar18 + fVar15 * fVar39,&uStack_120);
          FUN_00b76644(fVar18 + fVar35 * fVar39,&uStack_120);
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
        uVar10 = FUN_00b5f574(param_2);
        uStack_168 = param_2[1];
        QMessageLogger::debug
                  ((char *)&uStack_120,"renderBallPoint: pointCount=%d, mode=%d, color=%d",uVar10,
                   param_3);
      }
      fVar39 = (float)param_1[0xe];
      dVar43 = *(double *)(param_1 + 0x1e);
      fVar18 = (float)*(double *)(param_1 + 0x1c);
      iVar11 = FUN_00b5f574(param_2);
      uStack_b4 = 0;
      uStack_b0 = 0;
      uStack_5c = 0;
      uStack_58 = 0;
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
      uStack_94 = DAT_00b77860;
      uStack_8c = DAT_00b77868;
      uStack_a4 = uStack_b4;
      uStack_a0 = uStack_b0;
      uStack_7c = uStack_b4;
      uStack_78 = uStack_b0;
      uStack_6c = uStack_b4;
      uStack_68 = uStack_b0;
      uStack_108 = QImage::constBits();
      uVar10 = QImage::bytesPerLine();
      uStack_104 = CONCAT44(uStack_104._4_4_,uVar10);
      uVar10 = QImage::depth();
      pcStack_154 = (char *)param_1[0x24];
      iStack_158 = param_1[0x25];
      fStack_15c = (float)param_1[0x27];
      uStack_104 = CONCAT44(uVar10,(undefined4)uStack_104);
      iVar12 = param_1[0x26];
      iVar31 = QRegion::isEmpty();
      if (iVar31 == 0) {
        QRegion::operator=(aQStack_dc,(QRegion *)(param_1 + 0x28));
      }
      else {
        uStack_130._4_4_ = (float)(iVar12 + 1);
        uStack_130._0_4_ = (float)pcStack_154;
        iVar31 = (int)fStack_15c + 1;
        uStack_124 = (undefined1)iVar31;
        bStack_123 = (byte)((uint)iVar31 >> 8);
        uStack_122 = (undefined2)((uint)iVar31 >> 0x10);
        uStack_128 = (undefined2)iStack_158;
        uStack_126 = (undefined2)((uint)iStack_158 >> 0x10);
        auVar7._4_4_ = uStack_130._4_4_;
        auVar7._0_4_ = pcStack_154;
        auVar7._8_2_ = uStack_128;
        auVar7._10_2_ = uStack_126;
        auVar7[0xc] = uStack_124;
        auVar7[0xd] = bStack_123;
        auVar7._14_2_ = uStack_122;
        auVar42 = VectorSignedToFloat(auVar7,8);
        uStack_ec = auVar42._0_8_;
        uStack_e4 = auVar42._8_8_;
      }
      uStack_fc = FUN_0014cea0(param_1 + 6,*param_2,param_2[1],param_2[2]);
      fVar25 = DAT_00b77870;
      uStack_f8 = CONCAT22(uStack_f8._2_2_,
                           (ushort)(uStack_fc >> 8) & 0xf800 | (ushort)(uStack_fc >> 5) & 0x7e0 |
                           (ushort)((uStack_fc << 0x18) >> 0x1b));
      uVar10 = (undefined4)((ulonglong)in_d1 >> 0x20);
      if (param_3 == 1) {
        fStack_d0 = (float)param_2[8] * (float)param_1[0xe];
        uStack_120._0_2_ = CONCAT11(2,uStack_120._0_1_);
        if ((int)(unaff_r9 + 1) < iVar11) {
          iVar31 = unaff_r9 * 0xe;
          fVar38 = 0.25;
          fVar16 = DAT_00b77874;
          fVar37 = DAT_00b77878;
          do {
            iVar23 = param_2[4];
            pfVar27 = (float *)(iVar23 + iVar31);
            iVar12 = iVar23 + iVar31;
            iVar31 = iVar31 + 0xe;
            fVar40 = fVar18 + fVar39 * *pfVar27;
            fVar15 = *(float *)(iVar23 + iVar31);
            iVar23 = iVar23 + iVar31;
            fVar41 = (float)dVar43 + fVar39 * *(float *)(iVar12 + 4);
            fVar34 = (float)VectorUnsignedToFloat
                                      ((uint)*(byte *)(iVar23 + 0xd),(byte)(in_fpscr >> 0x15) & 3);
            fVar36 = fVar15 + *(float *)(iVar23 + 4) + fVar25;
            fVar35 = (float)VectorUnsignedToFloat
                                      ((uint)*(ushort *)(iVar23 + 10),(byte)(in_fpscr >> 0x15) & 3);
            uVar26 = ((uint)fVar36 ^ (uint)fVar36 >> 0x10) * 0x45d9f3b;
            uVar26 = (uVar26 ^ uVar26 >> 0x10) * 0x45d9f3b;
            fVar35 = fVar35 * fVar38 * fVar39;
            uStack_120 = CONCAT44(fVar35,(undefined4)uStack_120);
            uStack_f4 = (&DAT_013aea6c)[((uVar26 ^ uVar26 >> 0x10) & 3) * 3];
            in_fpscr = in_fpscr & 0xfffffff | (uint)(fVar34 / fVar16 < fVar37) << 0x1f;
            bVar33 = SUB41(in_fpscr >> 0x1f,0);
            uVar24 = uStack_f4;
            if (bVar33) {
              uVar24 = 1;
            }
            uVar19 = (undefined1)uVar24;
            if (!bVar33) {
              uVar19 = 0;
            }
            uStack_f0 = CONCAT31(uStack_f0._1_3_,uVar19);
            if (uStack_bc._2_1_ == '\x02') {
              if ((uStack_5c & 0xff) == 0) {
                FUN_00b6825c(uStack_7c,uVar17,uStack_74,uVar10,uStack_6c,uStack_68,uStack_64,
                             uStack_60,&uStack_120);
                bVar33 = uStack_5c._1_1_ == '\0';
                uStack_5c = CONCAT31(uStack_5c._1_3_,1);
                if ((bVar33) && (uStack_bc._2_1_ == '\x02')) {
LAB_00b77a38:
                  FUN_00b6825c(uStack_b4,uVar17,uStack_ac,uVar10,uStack_a4,uStack_a0,uStack_9c,
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
            uStack_94 = CONCAT44(fVar41,fVar40);
            uStack_8c = CONCAT44(fStack_d0,fVar35);
            uStack_84 = uStack_bc;
            uStack_80 = uStack_120._1_1_;
            fStack_150 = fVar40;
            fStack_14c = fVar41;
            fStack_148 = fVar35;
            fStack_cc = fVar40;
            fStack_c8 = fVar41;
            fStack_c4 = fVar35;
            FUN_00b76644(fVar18 + fVar39 * fVar15,&uStack_120);
            FUN_00b76860(&uStack_120);
          } while (iVar31 != iVar11 * 0xe + -0xe);
        }
      }
      else {
        uStack_120._0_2_ = CONCAT11(2,uStack_120._0_1_);
        if ((int)(unaff_r9 + 1) < iVar11) {
          iVar31 = unaff_r9 * 0xe;
          fVar38 = 0.25;
          fVar16 = DAT_00b77874;
          fVar37 = DAT_00b77878;
          do {
            iVar23 = param_2[4];
            pfVar27 = (float *)(iVar23 + iVar31);
            iVar12 = iVar23 + iVar31;
            iVar31 = iVar31 + 0xe;
            fVar15 = *(float *)(iVar23 + iVar31);
            iVar23 = iVar23 + iVar31;
            fVar41 = fVar18 + fVar39 * *pfVar27;
            fVar34 = (float)VectorUnsignedToFloat
                                      ((uint)*(byte *)(iVar23 + 0xd),(byte)(in_fpscr >> 0x15) & 3);
            fVar40 = (float)dVar43 + fVar39 * *(float *)(iVar12 + 4);
            fVar35 = (float)VectorUnsignedToFloat
                                      ((uint)*(ushort *)(iVar23 + 10),(byte)(in_fpscr >> 0x15) & 3);
            fVar36 = *(float *)(iVar23 + 4) + fVar15 + fVar25;
            fVar35 = fVar35 * fVar38 * fVar39;
            uVar26 = ((uint)fVar36 ^ (uint)fVar36 >> 0x10) * 0x45d9f3b;
            uVar26 = (uVar26 ^ uVar26 >> 0x10) * 0x45d9f3b;
            uStack_120 = CONCAT44(fVar35,(undefined4)uStack_120);
            in_fpscr = in_fpscr & 0xfffffff | (uint)(fVar34 / fVar16 < fVar37) << 0x1f;
            uStack_f4 = (&DAT_013aea6c)[((uVar26 ^ uVar26 >> 0x10) & 3) * 3];
            bVar33 = SUB41(in_fpscr >> 0x1f,0);
            uVar24 = uStack_f4;
            if (bVar33) {
              uVar24 = 1;
            }
            uVar19 = (undefined1)uVar24;
            if (!bVar33) {
              uVar19 = 0;
            }
            uStack_f0 = CONCAT31(uStack_f0._1_3_,uVar19);
            if (uStack_bc._2_1_ == '\x02') {
              if ((uStack_5c & 0xff) == 0) {
                FUN_00b6825c(uStack_7c,uVar17,uStack_74,uVar10,uStack_6c,uStack_68,uStack_64,
                             uStack_60,&uStack_120);
                bVar33 = uStack_5c._1_1_ == '\0';
                uStack_5c = CONCAT31(uStack_5c._1_3_,1);
                if ((bVar33) && (uStack_bc._2_1_ == '\x02')) goto LAB_00b77734;
                fVar35 = uStack_120._4_4_;
              }
              else if (uStack_5c._1_1_ == '\0') {
LAB_00b77734:
                FUN_00b6825c(uStack_b4,uVar17,uStack_ac,uVar10,uStack_a4,uStack_a0,uStack_9c,
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
            uStack_94 = CONCAT44(fVar40,fVar41);
            uStack_8c = CONCAT44(fStack_d0,fVar35);
            uStack_84 = uStack_bc;
            uStack_80 = uStack_120._1_1_;
            uStack_140._0_4_ = fVar41;
            uStack_140._4_4_ = fVar40;
            uStack_138._0_4_ = fVar35;
            fStack_cc = fVar41;
            fStack_c8 = fVar40;
            fStack_c4 = fVar35;
            FUN_00b76644(fVar18 + fVar39 * fVar15,&uStack_120);
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
        uVar10 = FUN_00b5f574(param_2);
        QMessageLogger::debug
                  ((char *)&uStack_120,"renderMarker: pointCount=%d, mode=%d, color=%d",uVar10,
                   param_3);
      }
      dVar43 = *(double *)(param_1 + 0x1e);
      fVar18 = (float)*(double *)(param_1 + 0x1c);
      fVar39 = (float)param_1[0xe];
      iVar11 = FUN_00b5f574(param_2,param_2,param_3,0);
      bVar33 = param_3 == 0;
      uStack_b4 = 0;
      uStack_b0 = 0;
      uStack_5c = 0;
      uStack_58 = 0;
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
      uStack_78 = uStack_b0;
      uStack_6c = uStack_b4;
      uStack_68 = uStack_b0;
      uStack_108 = QImage::constBits();
      uVar10 = QImage::bytesPerLine();
      uStack_104 = CONCAT44(uStack_104._4_4_,uVar10);
      uVar10 = QImage::depth();
      fStack_15c = (float)param_1[0x25];
      iStack_158 = param_1[0x26];
      pcStack_154 = (char *)param_1[0x27];
      uStack_104 = CONCAT44(uVar10,(undefined4)uStack_104);
      fVar25 = (float)param_1[0x24];
      iVar31 = QRegion::isEmpty();
      if (iVar31 == 0) {
        QRegion::operator=(aQStack_dc,(QRegion *)(param_1 + 0x28));
      }
      else {
        uStack_138._0_4_ = fStack_15c;
        uStack_140._4_4_ = (float)(iStack_158 + 1);
        uStack_138._4_4_ = (float)((int)pcStack_154 + 1);
        auVar6._4_4_ = uStack_140._4_4_;
        auVar6._0_4_ = fVar25;
        auVar6._8_4_ = fStack_15c;
        auVar6._12_4_ = uStack_138._4_4_;
        auVar42 = VectorSignedToFloat(auVar6,8);
        uStack_ec = auVar42._0_8_;
        uStack_e4 = auVar42._8_8_;
        uStack_140._0_4_ = fVar25;
      }
      uStack_fc = FUN_0014cea0(param_1 + 6,*param_2,param_2[1],param_2[2]);
      fVar25 = DAT_00b77368;
      bVar33 = param_3 == 1;
      fVar16 = extraout_s15_00;
      if (bVar33) {
        fVar16 = (float)param_2[8];
      }
      if (bVar33) {
        fVar16 = fVar16 * (float)param_1[0xe];
      }
      uStack_f8 = CONCAT22(uStack_f8._2_2_,
                           (ushort)(uStack_fc >> 8) & 0xf800 | (ushort)(uStack_fc >> 5) & 0x7e0 |
                           (ushort)((uStack_fc << 0x18) >> 0x1b));
      if (bVar33) {
        fStack_d0 = fVar16;
      }
      if ((int)(unaff_r9 + 2) < iVar11) {
        iVar31 = unaff_r9 * 0xe;
        fVar16 = DAT_00b7736c;
        fVar37 = DAT_00b77370;
        do {
          iVar21 = param_2[4];
          iVar23 = iVar31 + 0x1c;
          iVar12 = iVar21 + iVar31;
          iVar32 = iVar21 + iVar23;
          pfVar27 = (float *)(iVar21 + iVar31);
          iVar31 = iVar31 + 0xe;
          fVar38 = *(float *)(iVar21 + iVar23);
          uStack_130._4_4_ = *(float *)(iVar32 + 4);
          uVar26 = *(uint *)(iVar32 + 8);
          fVar35 = *(float *)(iVar21 + iVar31);
          uStack_128 = (undefined2)uVar26;
          uStack_126 = (undefined2)(uVar26 >> 0x10);
          fVar34 = fVar38 + uStack_130._4_4_ + fVar25;
          uStack_124 = (undefined1)*(undefined2 *)(iVar32 + 0xc);
          bStack_123 = (byte)((ushort)*(undefined2 *)(iVar32 + 0xc) >> 8);
          fVar15 = (float)VectorUnsignedToFloat(uVar26 & 0xffff,(byte)(in_fpscr >> 0x15) & 3);
          fVar15 = fVar15 * 0.25;
          uVar22 = ((uint)fVar34 ^ (uint)fVar34 >> 0x10) * 0x45d9f3b;
          uVar26 = in_fpscr & 0xfffffff;
          uVar20 = uVar26 | (uint)(fVar15 < 10.0) << 0x1f | (uint)(fVar15 == 10.0) << 0x1e;
          in_fpscr = uVar20 | (uint)NAN(fVar15) << 0x1c;
          uVar22 = (uVar22 ^ uVar22 >> 0x10) * 0x45d9f3b;
          bVar1 = (byte)(uVar20 >> 0x18);
          uStack_f4 = (&DAT_013aea6c)[((uVar22 ^ uVar22 >> 0x10) & 3) * 3];
          if ((bool)(bVar1 >> 6 & 1) || bVar1 >> 7 != ((byte)(in_fpscr >> 0x1c) & 1)) {
            fVar15 = (float)VectorUnsignedToFloat((uint)bStack_123,(byte)(in_fpscr >> 0x15) & 3);
            in_fpscr = uVar26 | (uint)(fVar15 / fVar16 < fVar37) << 0x1f;
            if (SUB41(in_fpscr >> 0x1f,0)) {
              uVar19 = 1;
            }
            else {
              uVar19 = 0;
            }
          }
          else {
            uVar19 = 1;
          }
          fVar15 = (float)VectorUnsignedToFloat
                                    ((uint)*(ushort *)(iVar32 + 10),(byte)(in_fpscr >> 0x15) & 3);
          uStack_f0 = CONCAT31(uStack_f0._1_3_,uVar19);
          fVar34 = fVar18 + *pfVar27 * fVar39;
          fVar36 = (float)dVar43 + *(float *)(iVar12 + 4) * fVar39;
          fVar15 = fVar15 * 0.25 * fVar39;
          uStack_120 = CONCAT44(fVar15,(undefined4)uStack_120);
          uStack_130._0_4_ = fVar38;
          if (uStack_bc._2_1_ == '\x02') {
            uVar10 = (undefined4)((ulonglong)dVar43 >> 0x20);
            if ((uStack_5c & 0xff) == 0) {
              FUN_00b6825c(uStack_7c,uVar17,uStack_74,uVar10,uStack_6c,uStack_68,uStack_64,uStack_60
                           ,&uStack_120);
              bVar33 = uStack_5c._1_1_ == '\0';
              uStack_5c = CONCAT31(uStack_5c._1_3_,1);
              if ((bVar33) && (uStack_bc._2_1_ == '\x02')) {
LAB_00b77300:
                FUN_00b6825c(uStack_b4,uVar17,uStack_ac,uVar10,uStack_a4,uStack_a0,uStack_9c,
                             uStack_98,&uStack_120,1);
                uStack_5c._0_2_ = CONCAT11(1,(undefined1)uStack_5c);
                fVar15 = uStack_120._4_4_;
              }
              else {
                fVar15 = uStack_120._4_4_;
              }
            }
            else if (uStack_5c._1_1_ == '\0') goto LAB_00b77300;
          }
          fStack_144 = fStack_d0;
          fStack_c0 = fStack_d0;
          uStack_b8 = CONCAT31(uStack_b8._1_3_,uStack_120._1_1_);
          uStack_bc._0_3_ = CONCAT12(1,(ushort)uStack_bc);
          uStack_bc = CONCAT13(uStack_120._0_1_,(undefined3)uStack_bc);
          uStack_94 = CONCAT44(fVar36,fVar34);
          uStack_8c = CONCAT44(fStack_d0,fVar15);
          uStack_84 = uStack_bc;
          uStack_80 = uStack_120._1_1_;
          fStack_150 = fVar34;
          fStack_14c = fVar36;
          fStack_148 = fVar15;
          fStack_cc = fVar34;
          fStack_c8 = fVar36;
          fStack_c4 = fVar15;
          FUN_00b76644(fVar18 + fVar35 * fVar39,&uStack_120);
          FUN_00b76644(fVar18 + fVar38 * fVar39,&uStack_120);
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
      puVar13 = (undefined2 *)param_1[0xc];
      if (puVar13 == (undefined2 *)0x0) {
        puVar13 = (undefined2 *)operator_new(200);
        memset(puVar13,0,200);
        *puVar13 = 0;
        *(undefined4 *)(puVar13 + 2) = 0x3f800000;
        *(undefined1 *)(puVar13 + 10) = 0;
        *(undefined4 *)(puVar13 + 0xc) = 0;
        *(undefined8 *)(puVar13 + 0xe) = 0;
        *(undefined4 *)(puVar13 + 0x16) = 0;
        *(undefined4 *)(puVar13 + 0x18) = 0;
        *(undefined4 *)(puVar13 + 0x12) = 0xff000000;
        *(undefined8 *)(puVar13 + 0x1a) = 0;
        *(undefined8 *)(puVar13 + 0x1e) = 0;
        QRegion::QRegion((QRegion *)(puVar13 + 0x22));
        pvVar29 = (void *)param_1[0xc];
        param_1[0xc] = puVar13;
        uVar9 = DAT_00b81fc0;
        uVar8 = DAT_00b81fb8;
        *(undefined4 *)(puVar13 + 0x26) = 0;
        puVar13[0x62] = 0;
        *(undefined8 *)(puVar13 + 0x52) = 0;
        *(undefined8 *)(puVar13 + 0x56) = 0;
        *(undefined8 *)(puVar13 + 0x5a) = 0;
        *(undefined8 *)(puVar13 + 0x5e) = 0;
        *(undefined8 *)(puVar13 + 0x28) = uVar8;
        *(undefined8 *)(puVar13 + 0x2c) = uVar9;
        *(undefined4 *)(puVar13 + 0x30) = 0;
        puVar13[0x33] = 0;
        *(undefined1 *)(puVar13 + 0x34) = 0;
        uVar9 = DAT_00b81fd0;
        uVar8 = DAT_00b81fc8;
        *(undefined8 *)(puVar13 + 0x36) = 0;
        *(undefined8 *)(puVar13 + 0x3a) = 0;
        *(undefined8 *)(puVar13 + 0x3e) = 0;
        *(undefined8 *)(puVar13 + 0x42) = 0;
        *(undefined8 *)(puVar13 + 0x46) = uVar8;
        *(undefined8 *)(puVar13 + 0x4a) = uVar9;
        puVar13[0x4f] = 0;
        *(undefined1 *)(puVar13 + 0x50) = 0;
        if (pvVar29 != (void *)0x0) {
          FUN_00b780c0(pvVar29);
          QRegion::~QRegion((QRegion *)((int)pvVar29 + 0x44));
          operator_delete(pvVar29,200);
          puVar13 = (undefined2 *)param_1[0xc];
        }
        uVar17 = QImage::constBits();
        *(undefined4 *)(puVar13 + 0xc) = uVar17;
        uVar17 = QImage::bytesPerLine();
        *(undefined4 *)(puVar13 + 0xe) = uVar17;
        uVar17 = QImage::depth();
        uVar10 = param_1[0x25];
        *(undefined4 *)(puVar13 + 0x10) = uVar17;
        uVar17 = param_1[0x24];
        iVar12 = param_1[0x26];
        iVar31 = param_1[0x27];
        iVar11 = QRegion::isEmpty();
        if (iVar11 == 0) {
          QRegion::operator=((QRegion *)(puVar13 + 0x22),(QRegion *)(param_1 + 0x28));
        }
        else {
          auVar3._4_4_ = iVar12 + 1;
          auVar3._0_4_ = uVar17;
          auVar3._8_4_ = uVar10;
          auVar3._12_4_ = iVar31 + 1;
          auVar42 = VectorSignedToFloat(auVar3,8);
          *(longlong *)(puVar13 + 0x1a) = auVar42._0_8_;
          *(longlong *)(puVar13 + 0x1e) = auVar42._8_8_;
        }
        puVar13 = (undefined2 *)param_1[0xc];
      }
      *puVar13 = 0x201;
      *(undefined4 *)(puVar13 + 0x12) = param_1[4];
      puVar13[0x14] = *(undefined2 *)(param_1 + 5);
      iVar11 = QImage::isNull();
      if (iVar11 == 0) {
        uVar17 = QImage::constBits();
        *(undefined4 *)(param_1[0xc] + 0x2c) = uVar17;
        uVar17 = QImage::bytesPerLine();
        iVar11 = param_1[0xc];
        *(undefined4 *)(iVar11 + 0x30) = uVar17;
      }
      else {
        iVar11 = param_1[0xc];
        *(undefined4 *)(iVar11 + 0x2c) = 0;
        *(undefined4 *)(iVar11 + 0x30) = 0;
      }
      FUN_00b78258(iVar11,param_2,param_3,param_1 + 0x10);
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
      fVar39 = (float)param_1[0xe];
      fVar18 = (float)*(double *)(param_1 + 0x1c);
      iVar11 = FUN_00b5f574(param_2);
      uStack_b4 = 0;
      uStack_b0 = 0;
      uStack_5c = 0;
      uStack_58 = 0;
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
      uStack_94 = DAT_00b81510;
      uStack_8c = DAT_00b81518;
      uStack_a4 = uStack_b4;
      uStack_a0 = uStack_b0;
      uStack_7c = uStack_b4;
      uStack_78 = uStack_b0;
      uStack_6c = uStack_b4;
      uStack_68 = uStack_b0;
      uStack_108 = QImage::constBits();
      uVar17 = QImage::bytesPerLine();
      uStack_104 = CONCAT44(uStack_104._4_4_,uVar17);
      uVar17 = QImage::depth();
      uVar24 = param_1[0x24];
      uVar10 = param_1[0x25];
      iVar12 = param_1[0x27];
      uStack_104 = CONCAT44(uVar17,(undefined4)uStack_104);
      iVar23 = param_1[0x26];
      iVar31 = QRegion::isEmpty();
      if (iVar31 == 0) {
        QRegion::operator=(aQStack_dc,(QRegion *)(param_1 + 0x28));
      }
      else {
        auVar4._4_4_ = iVar23 + 1;
        auVar4._0_4_ = uVar24;
        auVar4._8_4_ = uVar10;
        auVar4._12_4_ = iVar12 + 1;
        auVar42 = VectorSignedToFloat(auVar4,8);
        uStack_ec = auVar42._0_8_;
        uStack_e4 = auVar42._8_8_;
      }
      FUN_00b742c8(param_1,&uStack_120,param_2,param_3);
      fVar25 = DAT_00b81520;
      uStack_120._0_2_ = CONCAT11(2,uStack_120._0_1_);
      if ((int)(unaff_r8 + 1) < iVar11) {
        if (param_3 == 1) {
          iVar31 = unaff_r8 * 0xe;
          do {
            iVar12 = param_2[4];
            pfVar27 = (float *)(iVar12 + iVar31);
            iVar31 = iVar31 + 0xe;
            fVar16 = *(float *)(iVar12 + iVar31);
            fVar37 = (float)VectorUnsignedToFloat
                                      ((uint)*(ushort *)(iVar12 + iVar31 + 10),
                                       (byte)(in_fpscr >> 0x15) & 3);
            fVar38 = fVar16 + *(float *)(iVar12 + iVar31 + 4) + fVar25;
            uVar26 = ((uint)fVar38 ^ (uint)fVar38 >> 0x10) * 0x45d9f3b;
            uVar26 = (uVar26 ^ uVar26 >> 0x10) * 0x45d9f3b;
            uStack_120 = CONCAT44(fVar37 * 0.25 * fVar39,(undefined4)uStack_120);
            uStack_f4 = *(undefined4 *)(&DAT_013aeafc + ((uVar26 ^ uVar26 >> 0x10) & 3) * 0xc);
            FUN_00b76304(fVar18 + fVar39 * *pfVar27,&uStack_120);
            FUN_00b76644(fVar18 + fVar39 * fVar16,&uStack_120);
            FUN_00b76860(&uStack_120);
          } while (iVar31 != iVar11 * 0xe + -0xe);
        }
        else {
          iVar31 = unaff_r8 * 0xe;
          do {
            iVar12 = param_2[4];
            pfVar27 = (float *)(iVar12 + iVar31);
            iVar31 = iVar31 + 0xe;
            fVar16 = *(float *)(iVar12 + iVar31);
            fVar37 = (float)VectorUnsignedToFloat
                                      ((uint)*(ushort *)(iVar12 + iVar31 + 10),
                                       (byte)(in_fpscr >> 0x15) & 3);
            fVar38 = *(float *)(iVar12 + iVar31 + 4) + fVar16 + fVar25;
            uVar26 = ((uint)fVar38 ^ (uint)fVar38 >> 0x10) * 0x45d9f3b;
            uVar26 = (uVar26 ^ uVar26 >> 0x10) * 0x45d9f3b;
            uStack_120 = CONCAT44(fVar37 * 0.25 * fVar39,(undefined4)uStack_120);
            uStack_f4 = *(undefined4 *)(&DAT_013aeafc + ((uVar26 ^ uVar26 >> 0x10) & 3) * 0xc);
            FUN_00b76304(fVar18 + fVar39 * *pfVar27,&uStack_120);
            FUN_00b76644(fVar18 + fVar39 * fVar16,&uStack_120);
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
      iVar11 = param_1[10];
      if (iVar11 == 0) {
        puVar13 = (undefined2 *)operator_new(0x100);
        memset(puVar13,0,0x100);
        FUN_00b745e0(puVar13);
        pvVar29 = (void *)param_1[10];
        param_1[10] = puVar13;
        if (pvVar29 != (void *)0x0) {
          FUN_00b7f218(pvVar29);
          QRegion::~QRegion((QRegion *)((int)pvVar29 + 0x3c));
          operator_delete(pvVar29,0x100);
          puVar13 = (undefined2 *)param_1[10];
        }
        *puVar13 = 0x201;
        uVar17 = QImage::constBits();
        *(undefined4 *)(puVar13 + 0xc) = uVar17;
        uVar17 = QImage::bytesPerLine();
        *(undefined4 *)(puVar13 + 0xe) = uVar17;
        uVar17 = QImage::depth();
        uVar10 = param_1[0x25];
        *(undefined4 *)(puVar13 + 0x10) = uVar17;
        uVar17 = param_1[0x24];
        iVar12 = param_1[0x26];
        iVar31 = param_1[0x27];
        iVar11 = QRegion::isEmpty();
        if (iVar11 == 0) {
          QRegion::operator=((QRegion *)(puVar13 + 0x1e),(QRegion *)(param_1 + 0x28));
        }
        else {
          auVar2._4_4_ = iVar12 + 1;
          auVar2._0_4_ = uVar17;
          auVar2._8_4_ = uVar10;
          auVar2._12_4_ = iVar31 + 1;
          auVar42 = VectorSignedToFloat(auVar2,8);
          *(longlong *)(puVar13 + 0x16) = auVar42._0_8_;
          *(longlong *)(puVar13 + 0x1a) = auVar42._8_8_;
        }
        iVar11 = param_1[10];
      }
      fVar39 = (float)param_1[0xe];
      uVar24 = param_2[2];
      uVar17 = *param_2;
      uVar10 = param_2[1];
      *(float *)(iVar11 + 0x44) = DAT_00b8153c / fVar39;
      *(float *)(iVar11 + 0x48) = 1.5 / fVar39;
      uVar26 = FUN_0014cea0(param_1 + 6,uVar17,uVar10,uVar24);
      *(uint *)(iVar11 + 0x24) = uVar26;
      bVar33 = param_3 == 1;
      fVar39 = extraout_s15_01;
      if (bVar33) {
        fVar39 = (float)param_2[8];
      }
      fVar18 = extraout_s14;
      if (bVar33) {
        fVar18 = (float)param_1[0xe];
      }
      if (bVar33) {
        fVar39 = fVar39 * fVar18;
      }
      *(ushort *)(iVar11 + 0x28) =
           (ushort)(uVar26 >> 8) & 0xf800 | (ushort)(uVar26 >> 5) & 0x7e0 |
           (ushort)((uVar26 << 0x18) >> 0x1b);
      uVar17 = param_1[10];
      if (bVar33) {
        *(float *)(iVar11 + 0x50) = fVar39;
      }
      FUN_00b8078c(uVar17,param_2,param_3,param_1 + 0x10);
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
      iVar11 = param_1[0xb];
      if (iVar11 == 0) {
        puVar13 = (undefined2 *)operator_new(0x100);
        memset(puVar13,0,0x100);
        FUN_00b745e0(puVar13);
        pvVar29 = (void *)param_1[0xb];
        param_1[0xb] = puVar13;
        if (pvVar29 != (void *)0x0) {
          FUN_00b7f218(pvVar29);
          QRegion::~QRegion((QRegion *)((int)pvVar29 + 0x3c));
          operator_delete(pvVar29,0x100);
          puVar13 = (undefined2 *)param_1[0xb];
        }
        *puVar13 = 0x201;
        uVar17 = QImage::constBits();
        *(undefined4 *)(puVar13 + 0xc) = uVar17;
        uVar17 = QImage::bytesPerLine();
        *(undefined4 *)(puVar13 + 0xe) = uVar17;
        uVar17 = QImage::depth();
        uVar10 = param_1[0x25];
        *(undefined4 *)(puVar13 + 0x10) = uVar17;
        uVar17 = param_1[0x24];
        iVar12 = param_1[0x26];
        iVar31 = param_1[0x27];
        iVar11 = QRegion::isEmpty();
        if (iVar11 == 0) {
          QRegion::operator=((QRegion *)(puVar13 + 0x1e),(QRegion *)(param_1 + 0x28));
        }
        else {
          auVar42._4_4_ = iVar12 + 1;
          auVar42._0_4_ = uVar17;
          auVar42._8_4_ = uVar10;
          auVar42._12_4_ = iVar31 + 1;
          auVar42 = VectorSignedToFloat(auVar42,8);
          *(longlong *)(puVar13 + 0x16) = auVar42._0_8_;
          *(longlong *)(puVar13 + 0x1a) = auVar42._8_8_;
        }
        iVar11 = param_1[0xb];
      }
      fVar39 = (float)param_1[0xe];
      uVar24 = param_2[2];
      uVar17 = *param_2;
      uVar10 = param_2[1];
      *(float *)(iVar11 + 0x44) = DAT_00b8153c / fVar39;
      *(float *)(iVar11 + 0x48) = 1.5 / fVar39;
      uVar26 = FUN_0014cea0(param_1 + 6,uVar17,uVar10,uVar24);
      *(uint *)(iVar11 + 0x24) = uVar26;
      bVar33 = param_3 == 1;
      fVar39 = extraout_s15_02;
      if (bVar33) {
        fVar39 = (float)param_2[8];
      }
      fVar18 = extraout_s14_00;
      if (bVar33) {
        fVar18 = (float)param_1[0xe];
      }
      if (bVar33) {
        fVar39 = fVar39 * fVar18;
      }
      *(ushort *)(iVar11 + 0x28) =
           (ushort)(uVar26 >> 8) & 0xf800 | (ushort)(uVar26 >> 5) & 0x7e0 |
           (ushort)((uVar26 << 0x18) >> 0x1b);
      uVar17 = param_1[0xb];
      if (bVar33) {
        *(float *)(iVar11 + 0x50) = fVar39;
      }
      FUN_00b80b50(uVar17,param_2,param_3,param_1 + 0x10);
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
    piVar14 = (int *)FUN_0012c8f4((QDebug *)&iStack_158,"unhandled tool:");
    fStack_14c = (float)*piVar14;
    *(int *)((int)fStack_14c + 0x14) = *(int *)((int)fStack_14c + 0x14) + 1;
    qt_QMetaEnum_debugOperator
              ((QDebug *)&uStack_140,0x10ab704011db5b8,(QMetaObject *)&fStack_14c,pcVar30);
    QDebug::~QDebug((QDebug *)&uStack_140);
    QDebug::~QDebug((QDebug *)&fStack_14c);
    QDebug::~QDebug((QDebug *)&iStack_158);
    return;
  }
  if (param_2[1] == 1) goto switchD_00b80e74_caseD_4;
  FUN_00b709f4();
  pQVar28 = (QPen *)*param_1;
  if (pQVar28 == (QPen *)0x0) {
    return;
  }
  if ((int)param_2[5] < 2) {
    return;
  }
  QPainter::setCompositionMode(pQVar28,0);
  piVar14 = (int *)param_2[3];
  iVar11 = param_2[4];
  iVar31 = param_2[5];
  if (piVar14 == (int *)0x0) {
    if (iVar31 < 3) {
      return;
    }
  }
  else {
    DataMemoryBarrier(0xb);
    do {
      bVar33 = (bool)hasExclusiveAccess(piVar14);
    } while (!bVar33);
    *piVar14 = *piVar14 + 1;
    DataMemoryBarrier(0xb);
    if (iVar31 < 3) goto LAB_00b81844;
  }
  fVar39 = DAT_00b810ac;
  pfVar27 = (float *)(iVar11 + 0x1c);
  iVar11 = 2;
  do {
    fVar16 = SUB84(in_d0,0);
    fVar25 = pfVar27[1];
    fVar18 = *pfVar27;
    uStack_138 = (double)fVar25;
    uStack_140 = (double)fVar18;
    dVar43 = (double)*(float *)((int)pfVar27 + -10);
    uStack_128 = SUB82(dVar43,0);
    uStack_126 = (undefined2)((ulonglong)dVar43 >> 0x10);
    uStack_124 = (undefined1)((ulonglong)dVar43 >> 0x20);
    bStack_123 = (byte)((ulonglong)dVar43 >> 0x28);
    uStack_122 = (undefined2)((ulonglong)dVar43 >> 0x30);
    uStack_130 = (double)*(float *)((int)pfVar27 + -0xe);
    QPen::QPen(aQStack_198);
    QPen::setCapStyle(aQStack_198,0x20);
    DataMemoryBarrier(0xb);
    if ((DAT_013aeb2c & 1) == 0) {
      iVar12 = __cxa_guard_acquire(&DAT_013aeb2c);
      if (iVar12 != 0) {
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
    fVar37 = (float)VectorUnsignedToFloat
                              ((uint)*(ushort *)(pfVar27 + 2),(byte)(in_fpscr >> 0x15) & 3);
    fVar37 = fVar37 * 0.25;
    uVar26 = in_fpscr & 0xfffffff | (uint)(fVar37 < 20.0) << 0x1f | (uint)(fVar37 == 20.0) << 0x1e;
    in_fpscr = uVar26 | (uint)NAN(fVar37) << 0x1c;
    bVar1 = (byte)(uVar26 >> 0x18);
    if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1)) {
      fVar18 = fVar18 + fVar25 + fVar39;
      uVar26 = ((uint)fVar18 ^ (uint)fVar18 >> 0x10) * 0x45d9f3b;
      uVar26 = (uVar26 ^ uVar26 >> 0x10) * 0x45d9f3b;
      QBrush::QBrush((QBrush *)&fStack_14c,
                     (QPixmap *)(((uVar26 ^ uVar26 >> 0x10) & 3) * 0xc + DAT_00b81534));
      memcpy(&uStack_120,DAT_00b81524,0x48);
      uStack_d8 = uStack_d8 & 0xfc00;
      fVar18 = (float)VectorUnsignedToFloat
                                ((uint)*(byte *)(pfVar27 + 3),(byte)(in_fpscr >> 0x15) & 3);
      fVar16 = SUB84((double)(((fVar18 + fVar18) * DAT_00b81540) / DAT_00b81544),0);
      QTransform::rotateRadians(fVar16,&uStack_120,2);
      QBrush::setTransform((QTransform *)&fStack_14c);
      QPen::setBrush((QBrush *)aQStack_198);
      QBrush::~QBrush((QBrush *)&fStack_14c);
    }
    if (param_2[1] == 2) {
      QColor::QColor((QColor *)&uStack_120,3);
      QPen::setColor((QColor *)aQStack_198);
    }
    fVar18 = (float)VectorUnsignedToFloat
                              ((uint)*(ushort *)((int)pfVar27 + 10),(byte)(in_fpscr >> 0x15) & 3);
    dVar43 = (double)VectorSignedToFloat((int)(fVar18 * 0.25),(byte)(in_fpscr >> 0x15) & 3);
    FUN_00b5f7fc(0x3f800000,param_2);
    in_d0 = (double)fVar16;
    in_fpscr = in_fpscr & 0xfffffff;
    if (dVar43 == in_d0 || dVar43 < in_d0 != (NAN(dVar43) || NAN(in_d0))) {
      in_d0 = dVar43;
    }
    QPen::setWidthF((double)CONCAT44(in_stack_fffffe14,in_stack_fffffe10));
    QPainter::setPen(pQVar28);
    QPainter::drawLines((QLineF *)pQVar28,(int)&uStack_140);
    iVar11 = iVar11 + 1;
    pfVar27 = (float *)((int)pfVar27 + 0xe);
    QPen::~QPen(aQStack_198);
  } while (iVar11 < iVar31);
  if (piVar14 == (int *)0x0) {
    return;
  }
LAB_00b81844:
  DataMemoryBarrier(0xb);
  do {
    iVar11 = *piVar14;
    bVar33 = (bool)hasExclusiveAccess(piVar14);
  } while (!bVar33);
  *piVar14 = iVar11 + -1;
  DataMemoryBarrier(0xb);
  if (iVar11 + -1 != 0) {
    return;
  }
  free(piVar14);
  return;
}

