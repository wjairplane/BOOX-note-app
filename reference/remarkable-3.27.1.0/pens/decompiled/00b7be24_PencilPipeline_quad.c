
/* WARNING: Restarted to delay deadcode elimination for space: stack */

void FUN_00b7be24(float param_1,float param_2,float param_3,float param_4,float param_5,
                 float param_6,float param_7,float param_8,int param_9,int param_10,
                 undefined4 param_11,undefined4 param_12,undefined4 param_13,undefined4 param_14,
                 undefined4 param_15,undefined4 param_16,undefined4 param_17,undefined4 param_18,
                 undefined4 param_19,undefined4 param_20)

{
  uint uVar1;
  uint uVar2;
  byte bVar3;
  undefined8 uVar4;
  undefined8 uVar5;
  undefined8 uVar6;
  undefined8 uVar7;
  int iVar8;
  undefined4 *puVar9;
  undefined4 *puVar10;
  int iVar11;
  uint in_fpscr;
  undefined4 in_s8;
  undefined4 in_s9;
  undefined4 in_s10;
  undefined4 in_s11;
  undefined4 in_s12;
  float fVar12;
  undefined4 in_s13;
  float fVar13;
  undefined4 in_s14;
  float fVar14;
  undefined4 in_s15;
  float fVar15;
  float fVar16;
  float fVar17;
  undefined4 local_198;
  undefined4 local_194;
  undefined4 local_190;
  undefined4 local_18c;
  undefined4 local_188;
  undefined4 local_184;
  undefined4 local_180;
  undefined4 local_17c;
  float local_178;
  float local_174;
  float local_170;
  float local_16c;
  float local_168;
  float fStack_164;
  float local_160;
  float local_15c;
  undefined4 local_158;
  undefined4 local_154;
  undefined4 local_150;
  undefined4 local_14c;
  undefined4 local_148;
  undefined4 local_144;
  undefined4 local_140;
  undefined4 local_13c;
  undefined4 local_138;
  undefined4 local_134;
  undefined4 local_130;
  undefined4 local_12c;
  undefined4 local_128;
  undefined4 local_124;
  undefined4 local_120;
  undefined4 local_11c;
  undefined4 local_118;
  undefined4 local_114;
  undefined4 local_110;
  undefined4 local_10c;
  undefined4 local_108;
  undefined4 local_104;
  undefined4 local_100;
  undefined4 local_fc;
  undefined4 local_f8;
  undefined4 local_f4;
  undefined4 local_f0;
  undefined4 local_ec;
  undefined4 local_e8;
  undefined4 local_e4;
  undefined4 local_e0;
  undefined4 local_dc;
  undefined8 local_c8;
  undefined8 local_c0;
  float local_b8;
  float local_b4;
  undefined8 local_b0;
  undefined8 local_a8;
  float local_a0;
  float local_9c;
  undefined8 local_98;
  undefined8 local_90;
  float local_88;
  float local_84;
  undefined8 local_80;
  undefined8 local_78;
  float local_70;
  float local_6c;
  
  uVar6 = CONCAT44(param_2,param_1);
  uVar7 = CONCAT44(param_4,param_3);
  fVar16 = param_7;
  fVar17 = param_6;
  local_198 = in_s12;
  local_194 = in_s13;
  local_190 = in_s14;
  local_18c = in_s15;
  local_188 = in_s8;
  local_184 = in_s9;
  local_180 = in_s10;
  local_17c = in_s11;
  local_178 = param_5;
  local_174 = param_6;
  local_170 = param_7;
  local_16c = param_8;
  local_168 = param_1;
  fStack_164 = param_2;
  local_160 = param_3;
  local_15c = param_4;
  if ((param_10 != 0) &&
     (in_fpscr = in_fpscr & 0xfffffff |
                 (uint)((param_8 - param_6) * (param_4 - param_2) +
                        (param_7 - param_5) * (param_3 - param_1) < 0.0) << 0x1f,
     SUB41(in_fpscr >> 0x1f,0))) {
    FUN_00b753cc(&local_198);
    fVar16 = param_5;
    fVar17 = param_8;
    param_8 = param_6;
    param_5 = param_7;
  }
  uVar4 = CONCAT44(fVar17,param_5);
  uVar5 = CONCAT44(param_4,param_3);
  local_138 = local_188;
  local_134 = local_184;
  local_130 = local_180;
  local_12c = local_17c;
  iVar11 = param_9 + 0x18;
  local_128 = param_13;
  local_124 = param_14;
  local_120 = param_15;
  local_11c = param_16;
  local_118 = local_198;
  local_114 = local_194;
  local_110 = local_190;
  local_10c = local_18c;
  iVar8 = QRegion::isEmpty();
  if (iVar8 == 0) {
    puVar9 = (undefined4 *)QRegion::begin();
    puVar10 = (undefined4 *)QRegion::end();
    for (; puVar9 != puVar10; puVar9 = puVar9 + 4) {
      fVar14 = (float)VectorSignedToFloat(*puVar9,(byte)(in_fpscr >> 0x15) & 3);
      fVar12 = (float)VectorSignedToFloat(puVar9[1],(byte)(in_fpscr >> 0x15) & 3);
      uVar1 = in_fpscr & 0xfffffff;
      uVar2 = uVar1 | (uint)(fVar14 < param_1) << 0x1f | (uint)(fVar14 == param_1) << 0x1e;
      in_fpscr = uVar2 | (uint)(NAN(fVar14) || NAN(param_1)) << 0x1c;
      fVar15 = (float)VectorSignedToFloat(puVar9[2] + 1,(byte)(in_fpscr >> 0x15) & 3);
      fVar13 = (float)VectorSignedToFloat(puVar9[3] + 1,(byte)(in_fpscr >> 0x15) & 3);
      bVar3 = (byte)(uVar2 >> 0x18);
      *(float *)(param_9 + 0x1c) = fVar14;
      *(float *)(param_9 + 0x24) = fVar12;
      *(float *)(param_9 + 0x20) = fVar15;
      *(float *)(param_9 + 0x28) = fVar13;
      local_108 = local_138;
      local_104 = local_134;
      local_100 = local_130;
      local_fc = local_12c;
      local_f8 = local_128;
      local_f4 = local_124;
      local_f0 = local_120;
      local_ec = local_11c;
      local_e8 = local_118;
      local_e4 = local_114;
      local_e0 = local_110;
      local_dc = local_10c;
      if (((((!(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1)) ||
            (uVar2 = uVar1 | (uint)(fVar14 < param_3) << 0x1f | (uint)(fVar14 == param_3) << 0x1e,
            in_fpscr = uVar2 | (uint)(NAN(fVar14) || NAN(param_3)) << 0x1c,
            bVar3 = (byte)(uVar2 >> 0x18),
            !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))) ||
           (in_fpscr = uVar1 | (uint)(param_5 < fVar14) << 0x1f, SUB41(in_fpscr >> 0x1f,0))) ||
          (((in_fpscr = uVar1 | (uint)(fVar15 < param_1) << 0x1f, SUB41(in_fpscr >> 0x1f,0) ||
            (in_fpscr = uVar1 | (uint)(fVar15 < param_3) << 0x1f, SUB41(in_fpscr >> 0x1f,0))) ||
           ((uVar2 = uVar1 | (uint)(param_5 < fVar15) << 0x1f | (uint)(param_5 == fVar15) << 0x1e,
            in_fpscr = uVar2 | (uint)(NAN(param_5) || NAN(fVar15)) << 0x1c,
            bVar3 = (byte)(uVar2 >> 0x18),
            !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1) ||
            ((uVar2 = uVar1 | (uint)(fVar12 < param_2) << 0x1f | (uint)(fVar12 == param_2) << 0x1e,
             in_fpscr = uVar2 | (uint)(NAN(fVar12) || NAN(param_2)) << 0x1c,
             bVar3 = (byte)(uVar2 >> 0x18),
             !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1) ||
             (uVar2 = uVar1 | (uint)(fVar12 < param_4) << 0x1f | (uint)(fVar12 == param_4) << 0x1e,
             in_fpscr = uVar2 | (uint)(NAN(fVar12) || NAN(param_4)) << 0x1c,
             bVar3 = (byte)(uVar2 >> 0x18),
             !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))))))))) ||
         ((in_fpscr = uVar1 | (uint)(fVar17 < fVar12) << 0x1f, SUB41(in_fpscr >> 0x1f,0) ||
          (((in_fpscr = uVar1 | (uint)(fVar13 < param_2) << 0x1f, SUB41(in_fpscr >> 0x1f,0) ||
            (in_fpscr = uVar1 | (uint)(fVar13 < param_4) << 0x1f, SUB41(in_fpscr >> 0x1f,0))) ||
           (uVar1 = uVar1 | (uint)(fVar17 < fVar13) << 0x1f | (uint)(fVar17 == fVar13) << 0x1e,
           in_fpscr = uVar1 | (uint)(NAN(fVar17) || NAN(fVar13)) << 0x1c,
           bVar3 = (byte)(uVar1 >> 0x18),
           !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))))))) {
        local_b0 = uVar6;
        local_a8 = uVar7;
        local_a0 = param_5;
        local_9c = fVar17;
        FUN_00b7b73c(local_138,local_134,local_130,local_12c,local_128,local_124,local_120,local_11c
                     ,iVar11,param_1,param_2,param_3,param_4,param_5,fVar17);
      }
      else {
        local_98 = CONCAT44(local_134,local_138);
        local_90 = CONCAT44(local_12c,local_130);
        local_c8 = CONCAT44(local_124,local_128);
        local_c0 = CONCAT44(local_11c,local_120);
        local_80 = uVar6;
        local_78 = uVar7;
        local_70 = param_5;
        local_6c = fVar17;
        (**(code **)(**(int **)(param_9 + 0x18) + 8))
                  (local_138,local_134,local_130,local_12c,local_128,local_124,local_120,local_11c,
                   *(int **)(param_9 + 0x18),param_1,param_2,param_3,param_4,param_5,fVar17);
      }
    }
  }
  else {
    local_c8 = uVar6;
    local_c0 = uVar7;
    local_b8 = param_5;
    local_b4 = fVar17;
    FUN_00b7bc04(local_138,local_134,local_130,local_12c,local_128,local_124,local_120,local_11c,
                 iVar11,param_1,param_2,param_3,param_4,param_5,fVar17);
  }
  local_158 = local_198;
  local_154 = local_194;
  local_150 = local_190;
  local_14c = local_18c;
  local_148 = param_13;
  local_144 = param_14;
  local_140 = param_15;
  local_13c = param_16;
  local_138 = param_17;
  local_134 = param_18;
  local_130 = param_19;
  local_12c = param_20;
  iVar8 = QRegion::isEmpty();
  if (iVar8 == 0) {
    puVar9 = (undefined4 *)QRegion::begin();
    puVar10 = (undefined4 *)QRegion::end();
    for (; puVar9 != puVar10; puVar9 = puVar9 + 4) {
      fVar14 = (float)VectorSignedToFloat(*puVar9,(byte)(in_fpscr >> 0x15) & 3);
      fVar12 = (float)VectorSignedToFloat(puVar9[1],(byte)(in_fpscr >> 0x15) & 3);
      uVar1 = in_fpscr & 0xfffffff;
      in_fpscr = uVar1 | (uint)(param_5 < fVar14) << 0x1f;
      fVar15 = (float)VectorSignedToFloat(puVar9[2] + 1,(byte)(in_fpscr >> 0x15) & 3);
      fVar13 = (float)VectorSignedToFloat(puVar9[3] + 1,(byte)(in_fpscr >> 0x15) & 3);
      *(float *)(param_9 + 0x1c) = fVar14;
      *(float *)(param_9 + 0x24) = fVar12;
      *(float *)(param_9 + 0x20) = fVar15;
      *(float *)(param_9 + 0x28) = fVar13;
      local_118 = local_148;
      local_114 = local_144;
      local_110 = local_140;
      local_10c = local_13c;
      local_108 = local_138;
      local_104 = local_134;
      local_100 = local_130;
      local_fc = local_12c;
      if ((((SUB41(in_fpscr >> 0x1f,0)) ||
           (uVar2 = uVar1 | (uint)(fVar14 < param_3) << 0x1f | (uint)(fVar14 == param_3) << 0x1e,
           in_fpscr = uVar2 | (uint)(NAN(fVar14) || NAN(param_3)) << 0x1c,
           bVar3 = (byte)(uVar2 >> 0x18),
           !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))) ||
          ((in_fpscr = uVar1 | (uint)(fVar16 < fVar14) << 0x1f, SUB41(in_fpscr >> 0x1f,0) ||
           ((uVar2 = uVar1 | (uint)(param_5 < fVar15) << 0x1f | (uint)(param_5 == fVar15) << 0x1e,
            in_fpscr = uVar2 | (uint)(NAN(param_5) || NAN(fVar15)) << 0x1c,
            bVar3 = (byte)(uVar2 >> 0x18),
            !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1) ||
            (in_fpscr = uVar1 | (uint)(fVar15 < param_3) << 0x1f, SUB41(in_fpscr >> 0x1f,0))))))) ||
         ((uVar2 = uVar1 | (uint)(fVar16 < fVar15) << 0x1f | (uint)(fVar16 == fVar15) << 0x1e,
          in_fpscr = uVar2 | (uint)(NAN(fVar16) || NAN(fVar15)) << 0x1c,
          bVar3 = (byte)(uVar2 >> 0x18),
          !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1) ||
          (((((in_fpscr = uVar1 | (uint)(fVar17 < fVar12) << 0x1f, SUB41(in_fpscr >> 0x1f,0) ||
              (uVar2 = uVar1 | (uint)(fVar12 < param_4) << 0x1f | (uint)(fVar12 == param_4) << 0x1e,
              in_fpscr = uVar2 | (uint)(NAN(fVar12) || NAN(param_4)) << 0x1c,
              bVar3 = (byte)(uVar2 >> 0x18),
              !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))) ||
             (in_fpscr = uVar1 | (uint)(param_8 < fVar12) << 0x1f, SUB41(in_fpscr >> 0x1f,0))) ||
            ((uVar2 = uVar1 | (uint)(fVar17 < fVar13) << 0x1f | (uint)(fVar17 == fVar13) << 0x1e,
             in_fpscr = uVar2 | (uint)(NAN(fVar17) || NAN(fVar13)) << 0x1c,
             bVar3 = (byte)(uVar2 >> 0x18),
             !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1) ||
             (in_fpscr = uVar1 | (uint)(fVar13 < param_4) << 0x1f, SUB41(in_fpscr >> 0x1f,0))))) ||
           (uVar1 = uVar1 | (uint)(param_8 < fVar13) << 0x1f | (uint)(param_8 == fVar13) << 0x1e,
           in_fpscr = uVar1 | (uint)(NAN(param_8) || NAN(fVar13)) << 0x1c,
           bVar3 = (byte)(uVar1 >> 0x18),
           !(bool)(bVar3 >> 6 & 1) && bVar3 >> 7 == ((byte)(in_fpscr >> 0x1c) & 1))))))) {
        local_98 = uVar4;
        local_90 = uVar5;
        local_88 = fVar16;
        local_84 = param_8;
        FUN_00b7b73c(local_158,local_154,local_150,local_14c,local_148,local_144,local_140,local_13c
                     ,iVar11,param_5,fVar17,param_3,param_4,fVar16,param_8);
      }
      else {
        local_f8 = local_138;
        local_f4 = local_134;
        local_f0 = local_130;
        local_ec = local_12c;
        local_e8 = local_148;
        local_e4 = local_144;
        local_e0 = local_140;
        local_dc = local_13c;
        local_80 = uVar4;
        local_78 = uVar5;
        local_70 = fVar16;
        local_6c = param_8;
        (**(code **)(**(int **)(param_9 + 0x18) + 8))
                  (local_158,local_154,local_150,local_14c,local_148,local_144,local_140,local_13c,
                   *(int **)(param_9 + 0x18),param_5,fVar17,param_3,param_4,fVar16,param_8);
      }
    }
  }
  else {
    local_80 = uVar4;
    local_78 = uVar5;
    local_70 = fVar16;
    local_6c = param_8;
    FUN_00b7bc04(local_158,local_154,local_150,local_14c,local_148,local_144,local_140,local_13c,
                 iVar11,param_5,fVar17,param_3,param_4,fVar16,param_8);
  }
  *(int *)(param_9 + 0x34) = *(int *)(param_9 + 0x34) + 2;
  return;
}

