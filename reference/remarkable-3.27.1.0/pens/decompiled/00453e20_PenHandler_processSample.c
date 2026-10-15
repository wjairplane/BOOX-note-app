
void FUN_00453e20(int param_1,float param_2,float param_3,undefined4 param_4)

{
  bool bVar1;
  undefined8 uVar2;
  int iVar3;
  int iVar4;
  uint in_fpscr;
  undefined4 uVar5;
  double extraout_d1;
  undefined8 extraout_d1_00;
  undefined8 extraout_d1_01;
  undefined8 extraout_d2;
  undefined8 extraout_d2_00;
  undefined8 extraout_d3;
  float fStack00000004;
  float fStack00000008;
  undefined4 uStack0000000c;
  undefined4 in_stack_00000010;
  undefined4 in_stack_00000014;
  undefined4 uStack_c8;
  undefined4 uStack_c4;
  undefined4 uStack_c0;
  undefined4 uStack_bc;
  double dStack_b8;
  int iStack_a8;
  int iStack_a4;
  int iStack_a0;
  int iStack_9c;
  int iStack_98;
  int iStack_94;
  int iStack_90;
  int iStack_8c;
  undefined8 uStack_88;
  undefined8 uStack_80;
  undefined8 uStack_78;
  undefined8 uStack_70;
  undefined8 uStack_68;
  undefined4 uStack_60;
  int *piStack_5c;
  undefined4 uStack_58;
  undefined4 uStack_54;
  undefined8 uStack_50;
  undefined4 uStack_48;
  undefined4 uStack_40;
  undefined4 uStack_3c;
  undefined4 uStack_38;
  undefined4 uStack_34;
  undefined4 uStack_30;
  undefined4 uStack_2c;
  undefined4 uStack_28;
  undefined4 uStack_24;
  
  *(double *)(param_1 + 0x2f0) = (double)param_3;
  *(double *)(param_1 + 0x2e8) = (double)param_2;
  fStack00000004 = param_2;
  fStack00000008 = param_3;
  uStack0000000c = param_4;
  dStack_b8 = (double)QTransform::map((QPointF *)(param_1 + 0x90));
  fStack00000004 = (float)dStack_b8;
  fStack00000008 = (float)extraout_d1;
  if (*(char *)(param_1 + 0x3c) != '\0') {
    FUN_005d59bc();
    uVar5 = FUN_00b66450(param_1 + 0x30c);
    uStack_88 = FUN_00b63490(uVar5,*(undefined4 *)(param_1 + 0x38),param_1 + 0x240,&stack0x00000004,
                             0,*(undefined1 *)(param_1 + 0x308));
    uStack_68 = QTransform::mapRect((QRectF *)(param_1 + 0x40));
    uStack_60 = (undefined4)extraout_d1_00;
    piStack_5c = (int *)((ulonglong)extraout_d1_00 >> 0x20);
    uStack_58 = (undefined4)extraout_d2;
    uStack_54 = (undefined4)((ulonglong)extraout_d2 >> 0x20);
    QRectF::toAlignedRect();
    uStack_88 = VectorSignedToFloat(iStack_98,(byte)(in_fpscr >> 0x15) & 3);
    uStack_80 = VectorSignedToFloat(iStack_94,(byte)(in_fpscr >> 0x15) & 3);
    uStack_78 = VectorSignedToFloat((iStack_90 - iStack_98) + 1,(byte)(in_fpscr >> 0x15) & 3);
    uStack_70 = VectorSignedToFloat((iStack_8c - iStack_94) + 1,(byte)(in_fpscr >> 0x15) & 3);
    FUN_001d2cb4(&iStack_98,&uStack_88);
    if (*(int *)(param_1 + 0x2c) == 0) {
      FUN_005d59bc();
    }
    QImage::rect();
    QRect::operator&((QRect *)&iStack_a8,(QRect *)&iStack_98);
    iVar3 = QImage::isNull();
    if (((iVar3 == 0) && (iStack_a8 <= iStack_a0)) && (iStack_a4 <= iStack_9c)) {
      if (*(int *)(param_1 + 0x2c) == 0) {
        FUN_005d59bc();
      }
      QImage::copy((QRect *)&iStack_98);
    }
    else {
      QImage::QImage((QImage *)&iStack_98);
    }
    uStack_68 = *(undefined8 *)(param_1 + 0x280);
    uStack_60 = *(undefined4 *)(param_1 + 0x288);
    piStack_5c = (int *)*(undefined8 *)(param_1 + 0x28c);
    uStack_58 = (undefined4)((ulonglong)*(undefined8 *)(param_1 + 0x28c) >> 0x20);
    uStack_54 = *(undefined4 *)(param_1 + 0x294);
    if (piStack_5c != (int *)0x0) {
      DataMemoryBarrier(0xb);
      do {
        bVar1 = (bool)hasExclusiveAccess(piStack_5c);
      } while (!bVar1);
      *piStack_5c = *piStack_5c + 1;
      DataMemoryBarrier(0xb);
    }
    uStack_48 = *(undefined4 *)(param_1 + 0x2a0);
    uStack_50 = *(undefined8 *)(param_1 + 0x298);
    uStack_40 = *(undefined4 *)(param_1 + 0x2a8);
    uStack_3c = *(undefined4 *)(param_1 + 0x2ac);
    uStack_38 = *(undefined4 *)(param_1 + 0x2b0);
    uStack_34 = *(undefined4 *)(param_1 + 0x2b4);
    uStack_30 = *(undefined4 *)(param_1 + 0x2b8);
    uStack_2c = *(undefined4 *)(param_1 + 700);
    uStack_28 = *(undefined4 *)(param_1 + 0x2c0);
    uStack_24 = *(undefined4 *)(param_1 + 0x2c4);
    if ((int)uStack_68 == 6) {
      FUN_00b5f554(&uStack_68,0x16);
    }
    FUN_00b6c8e4(param_1 + 0x30c,&uStack_68,0);
    uVar2 = QRectF::operator|((QRectF *)(param_1 + 0xe8),(QRectF *)&uStack_88);
    *(undefined8 *)(param_1 + 0xe8) = uVar2;
    *(undefined8 *)(param_1 + 0xf0) = extraout_d1_01;
    *(undefined8 *)(param_1 + 0xf8) = extraout_d2_00;
    *(undefined8 *)(param_1 + 0x100) = extraout_d3;
    iVar3 = QImage::isNull();
    if (iVar3 == 0) {
      iVar3 = *(int *)(param_1 + 0x2c);
      if (iVar3 == 0) {
        iVar3 = FUN_005d59bc();
        iVar3 = *(int *)(iVar3 + 0x5c);
      }
      iVar4 = FUN_005d59bc();
      FUN_0044d64c(iStack_a8,iStack_a4,iStack_a0,iStack_9c,iVar3,&iStack_98,iVar4 + 0x60);
      QRect::operator|((QRect *)&uStack_c8,(QRect *)(param_1 + 0x314));
      *(undefined4 *)(param_1 + 0x314) = uStack_c8;
      *(undefined4 *)(param_1 + 0x318) = uStack_c4;
      *(undefined4 *)(param_1 + 0x31c) = uStack_c0;
      *(undefined4 *)(param_1 + 800) = uStack_bc;
    }
    if (piStack_5c != (int *)0x0) {
      DataMemoryBarrier(0xb);
      do {
        iVar3 = *piStack_5c;
        bVar1 = (bool)hasExclusiveAccess(piStack_5c);
      } while (!bVar1);
      *piStack_5c = iVar3 + -1;
      DataMemoryBarrier(0xb);
      if (iVar3 + -1 == 0) {
        free(piStack_5c);
      }
    }
    QImage::~QImage((QImage *)&iStack_98);
  }
  *(undefined4 *)(param_1 + 0x2f8) = *(undefined4 *)(param_1 + 0x2e8);
  *(undefined4 *)(param_1 + 0x2fc) = *(undefined4 *)(param_1 + 0x2ec);
  *(undefined4 *)(param_1 + 0x300) = *(undefined4 *)(param_1 + 0x2f0);
  *(undefined4 *)(param_1 + 0x304) = *(undefined4 *)(param_1 + 0x2f4);
  *(float *)(param_1 + 0x2d0) = fStack00000004;
  *(float *)(param_1 + 0x2d4) = fStack00000008;
  *(undefined4 *)(param_1 + 0x2d8) = uStack0000000c;
  *(undefined4 *)(param_1 + 0x2dc) = in_stack_00000010;
  *(undefined4 *)(param_1 + 0x2e0) = in_stack_00000014;
  return;
}

