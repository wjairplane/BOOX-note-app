
void FUN_00b6bbf0(undefined4 *param_1)

{
  undefined4 uVar1;
  uint uVar2;
  QPainter *this;
  void *pvVar3;
  void *pvVar4;
  int iVar5;
  QImage aQStack_30 [8];
  undefined4 local_28;
  undefined4 local_24 [2];
  undefined4 local_1c;
  
  param_1 = (undefined4 *)*param_1;
  if (*(char *)(param_1 + 9) != '\0') {
    switch(*(undefined1 *)(param_1 + 8)) {
    case 0:
    case 1:
    case 2:
      (**(code **)(*(int *)param_1[7] + 0xc))();
      break;
    case 3:
      FUN_00b7cf00(*(undefined4 *)(param_1[7] + 4));
      break;
    case 4:
      iVar5 = param_1[7];
      FUN_00b74cd8(*(undefined4 *)(iVar5 + 4));
      if (*(int *)(iVar5 + 8) == 0) {
        FUN_00b71a58();
      }
      else {
        FUN_00b6eb78(iVar5);
      }
      pvVar3 = *(void **)(iVar5 + 0x14);
      while (pvVar3 != (void *)0x0) {
        uVar2 = *(uint *)(iVar5 + 0x28);
        pvVar4 = *(void **)((int)pvVar3 + 8);
        if (uVar2 < 0x20) {
          uVar1 = *(undefined4 *)(iVar5 + 0x24);
          *(undefined4 *)((int)pvVar3 + 0xc) = 0;
          *(undefined4 *)((int)pvVar3 + 8) = uVar1;
          *(void **)(iVar5 + 0x24) = pvVar3;
          *(uint *)(iVar5 + 0x28) = uVar2 + 1;
          pvVar3 = pvVar4;
        }
        else {
          free(pvVar3);
          pvVar3 = pvVar4;
        }
      }
      *(undefined8 *)(iVar5 + 0x14) = 0;
      *(undefined1 *)(*(int *)(iVar5 + 4) + 0x14) = 0;
      break;
    case 5:
      FUN_00b7a4c8(*(undefined4 *)(param_1[7] + 4));
      break;
    default:
      iVar5 = param_1[7];
      FUN_00b7a4c8(*(undefined4 *)(iVar5 + 4));
      pvVar3 = *(void **)(iVar5 + 0xc);
      while (pvVar3 != (void *)0x0) {
        uVar2 = *(uint *)(iVar5 + 0x20);
        pvVar4 = *(void **)((int)pvVar3 + 8);
        if (uVar2 < 0x20) {
          uVar1 = *(undefined4 *)(iVar5 + 0x1c);
          *(undefined4 *)((int)pvVar3 + 0xc) = 0;
          *(undefined4 *)((int)pvVar3 + 8) = uVar1;
          *(void **)(iVar5 + 0x1c) = pvVar3;
          *(uint *)(iVar5 + 0x20) = uVar2 + 1;
          pvVar3 = pvVar4;
        }
        else {
          free(pvVar3);
          pvVar3 = pvVar4;
        }
      }
      *(undefined8 *)(iVar5 + 0xc) = 0;
    }
    pvVar3 = (void *)param_1[0x31];
    *(undefined1 *)(param_1 + 9) = 0;
    while (pvVar4 = pvVar3, pvVar3 != (void *)0x0) {
      while( true ) {
        uVar2 = param_1[0x36];
        pvVar3 = *(void **)((int)pvVar4 + 8);
        if (uVar2 < 0x20) break;
        free(pvVar4);
        pvVar4 = pvVar3;
        if (pvVar3 == (void *)0x0) goto LAB_00b6bd40;
      }
      uVar1 = param_1[0x35];
      *(undefined4 *)((int)pvVar4 + 0xc) = 0;
      *(undefined4 *)((int)pvVar4 + 8) = uVar1;
      param_1[0x35] = pvVar4;
      param_1[0x36] = uVar2 + 1;
    }
LAB_00b6bd40:
    *(undefined8 *)(param_1 + 0x31) = 0;
    pvVar3 = (void *)param_1[0x38];
    while (pvVar3 != (void *)0x0) {
      while( true ) {
        uVar2 = param_1[0x3d];
        pvVar4 = *(void **)((int)pvVar3 + 8);
        if (uVar2 < 0x20) break;
        free(pvVar3);
        pvVar3 = pvVar4;
        if (pvVar4 == (void *)0x0) goto LAB_00b6bda0;
      }
      uVar1 = param_1[0x3c];
      *(undefined4 *)((int)pvVar3 + 0xc) = 0;
      *(undefined4 *)((int)pvVar3 + 8) = uVar1;
      param_1[0x3c] = pvVar3;
      param_1[0x3d] = uVar2 + 1;
      pvVar3 = pvVar4;
    }
LAB_00b6bda0:
    *(undefined8 *)(param_1 + 0x38) = 0;
  }
  if (param_1[10] != 0) {
    FUN_00b7f218();
  }
  if (param_1[0xb] != 0) {
    FUN_00b7f218();
  }
  if (param_1[0xc] != 0) {
    FUN_00b780c0();
  }
  QImage::QImage(aQStack_30);
  QPaintDevice::QPaintDevice((QPaintDevice *)local_24);
  local_24[0] = DAT_00b6bed0;
  local_1c = param_1[3];
  param_1[3] = local_28;
  local_28 = 0;
  QImage::~QImage((QImage *)local_24);
  QImage::~QImage(aQStack_30);
  this = (QPainter *)*param_1;
  *param_1 = 0;
  if (this == (QPainter *)0x0) {
    return;
  }
  QPainter::~QPainter(this);
  operator_delete(this,4);
  return;
}

