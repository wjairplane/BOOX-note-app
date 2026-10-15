
int * FUN_00b6b75c(int *param_1,undefined4 param_2,undefined4 param_3,undefined4 *param_4)

{
  int iVar1;
  undefined4 uVar2;
  undefined4 *puVar3;
  int *piVar4;
  QDebug aQStack_b8 [4];
  int local_b4;
  QDebug aQStack_b0 [4];
  int local_ac;
  QRegion aQStack_a8 [4];
  char local_a4;
  undefined8 local_a0;
  undefined8 local_98;
  undefined4 local_90;
  QRegion aQStack_38 [36];
  
  local_a4 = '\0';
  FUN_00b66210(&local_a0,param_2,param_3,*param_4,param_4[1],param_4[2],param_4[3],aQStack_a8);
  FUN_00b7f438(param_1,&local_a0);
  QRegion::~QRegion(aQStack_38);
  if (local_a4 != '\0') {
    local_a4 = '\0';
    QRegion::~QRegion(aQStack_a8);
  }
  iVar1 = FUN_00b6618c();
  if (*(char *)(iVar1 + 8) == '\0') {
    return param_1;
  }
  local_90 = *(undefined4 *)(iVar1 + 4);
  local_a0 = DAT_00b6b970;
  local_98 = 0;
  QMessageLogger::debug();
  uVar2 = FUN_0012c8f4(aQStack_a8,"New StrokeRenderer,");
  puVar3 = (undefined4 *)FUN_0012c8f4(uVar2," depth:");
  iVar1 = QImage::depth();
  QTextStream::operator<<((QTextStream *)*puVar3,iVar1);
  if (((QTextStream *)*puVar3)[0x1c] != (QTextStream)0x0) {
    QTextStream::operator<<((QTextStream *)*puVar3,' ');
  }
  piVar4 = (int *)FUN_0012c8f4(puVar3," clip:");
  local_ac = *piVar4;
  iVar1 = *param_1;
  *(int *)(local_ac + 0x14) = *(int *)(local_ac + 0x14) + 1;
  operator<<(aQStack_b0,&local_ac,iVar1 + 0x90);
  piVar4 = (int *)FUN_0012c8f4(aQStack_b0," xform:");
  local_b4 = *piVar4;
  *(int *)(local_b4 + 0x14) = *(int *)(local_b4 + 0x14) + 1;
  operator<<(aQStack_b8,&local_b4,param_3);
  QDebug::~QDebug(aQStack_b8);
  QDebug::~QDebug((QDebug *)&local_b4);
  QDebug::~QDebug(aQStack_b0);
  QDebug::~QDebug((QDebug *)&local_ac);
  QDebug::~QDebug((QDebug *)aQStack_a8);
  return param_1;
}

