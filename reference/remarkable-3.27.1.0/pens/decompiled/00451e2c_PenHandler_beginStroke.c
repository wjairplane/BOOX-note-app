
int FUN_00451e2c(int param_1,float param_2,float param_3,undefined4 param_4)

{
  bool bVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  int iVar4;
  int iVar5;
  int *piVar6;
  uint uVar7;
  undefined4 uVar8;
  undefined4 uVar9;
  int iVar10;
  char cVar11;
  float fVar12;
  float fVar13;
  double extraout_d1;
  double dVar14;
  float fStack00000004;
  float fStack00000008;
  undefined4 uStack0000000c;
  float in_stack_00000010;
  float in_stack_00000014;
  pthread_mutex_t *ppStack_c8;
  char cStack_c4;
  double dStack_c0;
  undefined4 uStack_b8;
  undefined4 uStack_b4;
  undefined4 uStack_b0;
  undefined4 uStack_ac;
  undefined4 uStack_a8;
  undefined4 uStack_a4;
  undefined4 uStack_a0;
  undefined4 uStack_9c;
  undefined4 uStack_98;
  undefined4 uStack_94;
  undefined4 uStack_90;
  undefined4 uStack_8c;
  undefined1 uStack_88;
  undefined8 uStack_80;
  undefined4 uStack_78;
  undefined8 uStack_74;
  undefined4 uStack_6c;
  undefined4 uStack_68;
  undefined4 uStack_64;
  undefined4 uStack_60;
  undefined4 uStack_58;
  undefined4 uStack_54;
  undefined4 uStack_50;
  undefined4 uStack_4c;
  undefined4 uStack_48;
  undefined4 uStack_44;
  undefined4 uStack_40;
  undefined4 uStack_3c;
  undefined1 uStack_38;
  
  fStack00000004 = param_2;
  fStack00000008 = param_3;
  uStack0000000c = param_4;
  iVar4 = FUN_00448044(param_1,param_2,param_3,param_4,in_stack_00000010,in_stack_00000014);
  if (iVar4 != 0) {
    ppStack_c8 = (pthread_mutex_t *)(param_1 + 8);
    iVar5 = pthread_mutex_lock(ppStack_c8);
    if (iVar5 != 0) {
                    /* WARNING: Subroutine does not return */
      std::__throw_system_error(iVar5);
    }
    cStack_c4 = '\x01';
    *(undefined1 *)(param_1 + 0x3c) = 1;
    *(undefined1 *)(param_1 + 0x308) = *(undefined1 *)(param_1 + 0x238);
    uVar8 = *(undefined4 *)(param_1 + 0x210);
    dVar14 = *(double *)(param_1 + 0x220);
    uVar9 = *(undefined4 *)(param_1 + 0x214);
    if (*(char *)(param_1 + 0x108) != '\0') {
      fVar12 = tanf(in_stack_00000010);
      fVar13 = tanf(in_stack_00000014);
      fVar12 = atanf(SQRT(fVar13 * fVar13 + fVar12 * fVar12));
      dVar14 = *(double *)(param_1 + 0x230);
      uVar8 = *(undefined4 *)(param_1 + 0x228);
      uVar9 = *(undefined4 *)(param_1 + 0x22c);
      if ((double)fVar12 < DAT_00452218 == (NAN((double)fVar12) || NAN(DAT_00452218))) {
        dVar14 = dVar14 * 0.25;
      }
    }
    FUN_00b62b50(SUB84((double)(float)dVar14,0),&dStack_c0,uVar8,uVar9,
                 *(undefined4 *)(param_1 + 0x218));
    uVar8 = uStack_6c;
    uVar2 = uStack_74;
    *(undefined4 *)(param_1 + 0x240) = dStack_c0._0_4_;
    *(undefined4 *)(param_1 + 0x248) = uStack_b8;
    *(undefined4 *)(param_1 + 0x24c) = uStack_b4;
    *(undefined4 *)(param_1 + 0x250) = uStack_b0;
    *(undefined4 *)(param_1 + 0x254) = uStack_ac;
    *(undefined4 *)(param_1 + 600) = uStack_a8;
    *(undefined4 *)(param_1 + 0x25c) = uStack_a4;
    *(undefined4 *)(param_1 + 0x260) = uStack_a0;
    *(undefined4 *)(param_1 + 0x264) = uStack_9c;
    *(undefined4 *)(param_1 + 0x268) = uStack_98;
    *(undefined4 *)(param_1 + 0x26c) = uStack_94;
    *(undefined4 *)(param_1 + 0x270) = uStack_90;
    *(undefined4 *)(param_1 + 0x274) = uStack_8c;
    *(undefined8 *)(param_1 + 0x280) = uStack_80;
    uStack_74 = 0;
    *(undefined1 *)(param_1 + 0x278) = uStack_88;
    *(undefined4 *)(param_1 + 0x288) = uStack_78;
    piVar6 = *(int **)(param_1 + 0x28c);
    uStack_6c = 0;
    *(undefined8 *)(param_1 + 0x28c) = uVar2;
    *(undefined4 *)(param_1 + 0x294) = uVar8;
    if (piVar6 == (int *)0x0) {
      *(undefined4 *)(param_1 + 0x298) = uStack_68;
      *(undefined4 *)(param_1 + 0x29c) = uStack_64;
      *(undefined4 *)(param_1 + 0x2a0) = uStack_60;
      *(undefined4 *)(param_1 + 0x2a8) = uStack_58;
      *(undefined4 *)(param_1 + 0x2ac) = uStack_54;
      *(undefined4 *)(param_1 + 0x2b0) = uStack_50;
      *(undefined4 *)(param_1 + 0x2b4) = uStack_4c;
      *(undefined4 *)(param_1 + 0x2b8) = uStack_48;
      *(undefined4 *)(param_1 + 700) = uStack_44;
      *(undefined4 *)(param_1 + 0x2c0) = uStack_40;
      *(undefined4 *)(param_1 + 0x2c4) = uStack_3c;
      *(undefined1 *)(param_1 + 0x2c8) = uStack_38;
    }
    else {
      DataMemoryBarrier(0xb);
      do {
        iVar5 = *piVar6;
        bVar1 = (bool)hasExclusiveAccess(piVar6);
      } while (!bVar1);
      *piVar6 = iVar5 + -1;
      DataMemoryBarrier(0xb);
      if (iVar5 + -1 == 0) {
        free(piVar6);
      }
      *(undefined4 *)(param_1 + 0x2a0) = uStack_60;
      *(undefined4 *)(param_1 + 0x298) = uStack_68;
      *(undefined4 *)(param_1 + 0x29c) = uStack_64;
      *(undefined4 *)(param_1 + 0x2a8) = uStack_58;
      *(undefined4 *)(param_1 + 0x2ac) = uStack_54;
      *(undefined4 *)(param_1 + 0x2b0) = uStack_50;
      *(undefined4 *)(param_1 + 0x2b4) = uStack_4c;
      *(undefined4 *)(param_1 + 0x2b8) = uStack_48;
      *(undefined4 *)(param_1 + 700) = uStack_44;
      *(undefined4 *)(param_1 + 0x2c0) = uStack_40;
      *(undefined4 *)(param_1 + 0x2c4) = uStack_3c;
      *(undefined1 *)(param_1 + 0x2c8) = uStack_38;
      if ((int *)uStack_74 != (int *)0x0) {
        DataMemoryBarrier(0xb);
        do {
          iVar5 = *(int *)uStack_74;
          bVar1 = (bool)hasExclusiveAccess((int *)uStack_74);
        } while (!bVar1);
        *(int *)uStack_74 = iVar5 + -1;
        DataMemoryBarrier(0xb);
        if (iVar5 + -1 == 0) {
          free((int *)uStack_74);
        }
      }
    }
    if (ppStack_c8 != (pthread_mutex_t *)0x0) {
      pthread_mutex_unlock(ppStack_c8);
      cStack_c4 = '\0';
    }
    piVar6 = (int *)FUN_005d59bc();
    if ((*(code **)(*piVar6 + 0x34) == (code *)&LAB_005c4fec) ||
       (uVar7 = (**(code **)(*piVar6 + 0x34))(), (uVar7 & 2) == 0)) {
      cVar11 = '\0';
    }
    else {
      DataMemoryBarrier(0xb);
      cVar11 = *(char *)(param_1 + 0x1f9);
      DataMemoryBarrier(0xb);
      if (cVar11 != '\0') {
        cVar11 = '\x01';
      }
    }
    iVar5 = *(int *)(param_1 + 0x2c);
    if (iVar5 == 0) {
      iVar5 = FUN_005d59bc();
      iVar5 = *(int *)(iVar5 + 0x5c);
    }
    if (*(char *)(param_1 + 0x310) != '\0') {
      *(undefined1 *)(param_1 + 0x310) = 0;
      FUN_00b6bbc0(param_1 + 0x30c);
    }
    iVar10 = param_1 + 0x30c;
    FUN_00b6b978(iVar10,iVar5,param_1 + 0x40,param_1 + 0x34);
    *(undefined1 *)(param_1 + 0x310) = 1;
    FUN_00b664b0(iVar10,cVar11);
    FUN_00b664f4(iVar10,0);
    FUN_00b664e8(iVar10,0);
    *(double *)(param_1 + 0x300) = (double)fStack00000008;
    *(double *)(param_1 + 0x2f8) = (double)fStack00000004;
    *(float *)(param_1 + 0x2d0) = fStack00000004;
    *(float *)(param_1 + 0x2d4) = fStack00000008;
    *(undefined4 *)(param_1 + 0x2d8) = uStack0000000c;
    *(float *)(param_1 + 0x2dc) = in_stack_00000010;
    *(float *)(param_1 + 0x2e0) = in_stack_00000014;
    dStack_c0 = (double)QTransform::map((QPointF *)(param_1 + 0x90));
    uVar3 = DAT_00452210;
    uVar2 = DAT_00452208;
    *(float *)(param_1 + 0x2d0) = (float)dStack_c0;
    *(float *)(param_1 + 0x2d4) = (float)extraout_d1;
    *(undefined8 *)(param_1 + 0x314) = uVar2;
    *(undefined8 *)(param_1 + 0x31c) = uVar3;
    if (cStack_c4 != '\0') {
      FUN_0036a5a8(&ppStack_c8);
    }
  }
  return iVar4;
}

