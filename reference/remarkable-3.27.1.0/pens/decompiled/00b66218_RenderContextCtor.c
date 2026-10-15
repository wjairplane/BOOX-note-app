
float * FUN_00b66218(float *param_1,float param_2,double *param_3,undefined4 param_4)

{
  QRect QVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  QRect *pQVar4;
  float fVar5;
  float *pfVar6;
  float in_r12;
  undefined4 uStack00000004;
  QRect *in_stack_00000014;
  float fStack_48;
  float fStack_44;
  float fStack_40;
  float fStack_3c;
  float afStack_34 [5];
  
  pQVar4 = in_stack_00000014;
  *param_1 = in_r12;
  pfVar6 = param_1 + 0x16;
  uStack00000004 = param_4;
  memcpy(param_1 + 2,DAT_00b66418,0x48);
  uVar3 = DAT_00b66400;
  uVar2 = DAT_00b663f8;
  *(ushort *)(param_1 + 0x14) = *(ushort *)(param_1 + 0x14) & 0xfc00;
  *(undefined8 *)pfVar6 = uVar2;
  *(undefined8 *)(param_1 + 0x18) = uVar3;
  QRegion::QRegion((QRegion *)(param_1 + 0x1a));
  uVar3 = DAT_00b66410;
  uVar2 = DAT_00b66408;
  *(undefined2 *)(param_1 + 0x1b) = 0x100;
  param_1[0x1c] = 0.0;
  param_1[0x1d] = 0.0;
  *(undefined8 *)(param_1 + 0x1e) = uVar2;
  *(undefined8 *)(param_1 + 0x20) = uVar3;
  *(undefined1 *)((int)param_1 + 0x6e) = 0;
  QImage::detach();
  *param_1 = (float)SQRT(ABS(((param_3[8] * param_3[4] - param_3[7] * param_3[5]) * *param_3 -
                             (param_3[8] * param_3[1] - param_3[7] * param_3[2]) * param_3[3]) +
                             (param_3[5] * param_3[1] - param_3[4] * param_3[2]) * param_3[6]));
  memcpy(param_1 + 2,param_3,0x4a);
  param_1[0x1c] = param_2;
  fVar5 = (float)QImage::bits();
  param_1[0x1d] = fVar5;
  fVar5 = (float)QImage::width();
  param_1[0x1e] = fVar5;
  fVar5 = (float)QImage::height();
  param_1[0x1f] = fVar5;
  fVar5 = (float)QImage::depth();
  param_1[0x20] = fVar5;
  fVar5 = (float)QImage::bytesPerLine();
  QVar1 = pQVar4[4];
  param_1[0x21] = fVar5;
  if (QVar1 == (QRect)0x0) {
    QImage::rect();
    QRect::operator&((QRect *)&fStack_48,(QRect *)&stack0x00000004);
    *pfVar6 = fStack_48;
    param_1[0x17] = fStack_44;
    param_1[0x18] = fStack_40;
    param_1[0x19] = fStack_3c;
  }
  else {
    QImage::rect();
    QRegion::operator&((QRegion *)afStack_34,pQVar4);
    fVar5 = param_1[0x1a];
    param_1[0x1a] = afStack_34[0];
    afStack_34[0] = fVar5;
    QRegion::~QRegion((QRegion *)afStack_34);
    QRegion::boundingRect();
    *pfVar6 = fStack_48;
    param_1[0x17] = fStack_44;
    param_1[0x18] = fStack_40;
    param_1[0x19] = fStack_3c;
  }
  return param_1;
}

