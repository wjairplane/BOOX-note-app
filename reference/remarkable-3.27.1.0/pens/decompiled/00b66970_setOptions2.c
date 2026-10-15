
void FUN_00b66970(undefined4 *param_1,undefined4 param_2,undefined4 param_3)

{
  undefined4 uVar1;
  QRect aQStack_30 [16];
  QRect aQStack_20 [20];
  
  uVar1 = *param_1;
  QTransform::mapRect(aQStack_30);
  QRect::operator&(aQStack_20,aQStack_30);
  FUN_00b66594(uVar1,aQStack_20,param_3);
  return;
}

