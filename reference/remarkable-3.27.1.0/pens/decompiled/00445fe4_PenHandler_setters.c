
void FUN_00445fe4(QObject *param_1,int param_2,uint param_3,undefined4 *param_4)

{
  QObject QVar1;
  undefined8 *puVar2;
  undefined4 *puVar3;
  undefined4 uVar4;
  int iVar5;
  code *pcVar6;
  int iVar7;
  QObject *pQVar8;
  undefined4 uVar9;
  int *piVar10;
  bool in_ZR;
  double dVar11;
  undefined4 uStack_80;
  undefined4 uStack_7c;
  undefined4 uStack_78;
  undefined4 uStack_74;
  undefined4 uStack_70;
  undefined4 uStack_6c;
  undefined8 uStack_68;
  char *pcStack_60;
  char *pcStack_5c;
  undefined4 uStack_58;
  undefined4 uStack_54;
  undefined4 uStack_50;
  undefined4 uStack_4c;
  char *pcStack_48;
  char *pcStack_44;
  undefined4 uStack_40;
  undefined4 uStack_3c;
  undefined8 uStack_38;
  char *pcStack_30;
  char *pcStack_2c;
  undefined4 uStack_28;
  undefined4 uStack_24;
  
  if (in_ZR) {
    switch(param_3) {
    case 0:
      uStack_38 = (ulonglong)(uint)param_4[1] << 0x20;
      QMetaObject::activate
                (param_1,(QMetaObject *)&PTR_PTR_staticMetaObject_00cce450,0,(void **)&uStack_38);
      return;
    case 1:
      iVar7 = 1;
      break;
    case 2:
      iVar7 = 2;
      break;
    case 3:
      iVar7 = 3;
      break;
    case 4:
      iVar7 = 4;
      break;
    case 5:
      iVar7 = 5;
      break;
    case 6:
      iVar7 = 6;
      break;
    case 7:
      iVar7 = 7;
      break;
    case 8:
      goto LAB_004461a4;
    default:
      goto switchD_00445ffc_default;
    }
    goto LAB_00446184;
  }
  if (param_2 == 5) {
    puVar3 = (undefined4 *)param_4[1];
    piVar10 = (int *)*param_4;
    pcVar6 = (code *)*puVar3;
    if (pcVar6 == FUN_00445164) {
      iVar7 = puVar3[1];
      if (iVar7 != 0) {
        return;
      }
    }
    else {
      if (pcVar6 != (code *)&UNK_00445194) {
        if (pcVar6 == (code *)&UNK_004451a8) {
          if (puVar3[1] != 0) {
            return;
          }
          *piVar10 = 2;
          return;
        }
        if (pcVar6 == (code *)&UNK_004451bc) {
          if (puVar3[1] != 0) {
            return;
          }
          *piVar10 = 3;
          return;
        }
        if (pcVar6 == (code *)&UNK_004451d0) {
          if (puVar3[1] != 0) {
            return;
          }
          *piVar10 = 4;
          return;
        }
        if (pcVar6 == (code *)&UNK_004451e4) {
          if (puVar3[1] != 0) {
            return;
          }
          *piVar10 = 5;
          return;
        }
        if (pcVar6 == (code *)&UNK_004451f8) {
          if (puVar3[1] != 0) {
            return;
          }
          *piVar10 = 6;
          return;
        }
        if (pcVar6 == (code *)&UNK_0044520c) {
          if (puVar3[1] != 0) {
            return;
          }
          *piVar10 = 7;
          return;
        }
        if (pcVar6 != (code *)&UNK_00445220) {
          return;
        }
        if (puVar3[1] != 0) {
          return;
        }
        *piVar10 = 8;
        return;
      }
      if (puVar3[1] != 0) {
        return;
      }
      iVar7 = 1;
    }
    *piVar10 = iVar7;
    return;
  }
  if (param_2 == 6) {
    param_4 = (undefined4 *)*param_4;
    if ((param_3 & 0xfffffffb) == 0) {
      uStack_38 = CONCAT44(uStack_38._4_4_,&DAT_0138d730);
      uVar4 = FUN_0013e458(&uStack_38);
      *param_4 = uVar4;
      return;
    }
    *param_4 = 0xffffffff;
    return;
  }
  if (param_2 == 1) {
    pQVar8 = (QObject *)*param_4;
    switch(param_3) {
    case 0:
      FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
      uVar4 = *(undefined4 *)(param_1 + 0x210);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      *(undefined4 *)pQVar8 = uVar4;
      return;
    case 1:
      FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
      uVar4 = *(undefined4 *)(param_1 + 0x214);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      *(undefined4 *)pQVar8 = uVar4;
      return;
    case 2:
      FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
      uVar4 = *(undefined4 *)(param_1 + 0x220);
      uVar9 = *(undefined4 *)(param_1 + 0x224);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      *(undefined4 *)pQVar8 = uVar4;
      *(undefined4 *)(pQVar8 + 4) = uVar9;
      return;
    case 3:
      FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
      uVar4 = *(undefined4 *)(param_1 + 0x218);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      *(undefined4 *)pQVar8 = uVar4;
      return;
    case 4:
      FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
      uVar4 = *(undefined4 *)(param_1 + 0x228);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      *(undefined4 *)pQVar8 = uVar4;
      return;
    case 5:
      FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
      uVar4 = *(undefined4 *)(param_1 + 0x22c);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      *(undefined4 *)pQVar8 = uVar4;
      return;
    case 6:
      FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
      uVar4 = *(undefined4 *)(param_1 + 0x230);
      uVar9 = *(undefined4 *)(param_1 + 0x234);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      *(undefined4 *)pQVar8 = uVar4;
      *(undefined4 *)(pQVar8 + 4) = uVar9;
      return;
    case 7:
      FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
      QVar1 = param_1[0x238];
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      *pQVar8 = QVar1;
      return;
    default:
      return;
    }
  }
  if (param_2 != 2) {
    return;
  }
  pQVar8 = (QObject *)*param_4;
  switch(param_3) {
  case 0:
    iVar7 = *(int *)pQVar8;
    FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
    puVar3 = DAT_004468b0;
    if (iVar7 != *(int *)(param_1 + 0x210)) {
      *(int *)(param_1 + 0x210) = iVar7;
      FUN_0078be94("/home/runner/work/xochitl/xochitl/src/xofm/libs/peninput/src/peninputhandler.cpp"
                   ,"setLineTool",0xd4,*puVar3,puVar3[1],param_1 + 0x210,*puVar3,puVar3[1],puVar3[2]
                   ,puVar3[3],puVar3[4],puVar3[5]);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      iVar7 = 1;
      goto LAB_00446184;
    }
    break;
  case 1:
    iVar7 = *(int *)pQVar8;
    FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
    puVar3 = DAT_004468bc;
    if (iVar7 != *(int *)(param_1 + 0x214)) {
      *(int *)(param_1 + 0x214) = iVar7;
      FUN_0078bd3c("/home/runner/work/xochitl/xochitl/src/xofm/libs/peninput/src/peninputhandler.cpp"
                   ,"setLineColor",0xe7,*puVar3,puVar3[1],param_1 + 0x214);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      iVar7 = 2;
      goto LAB_00446184;
    }
    break;
  case 2:
    dVar11 = *(double *)pQVar8;
    FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
    puVar3 = DAT_004468b8;
    if (dVar11 != *(double *)(param_1 + 0x220)) {
      *(double *)(param_1 + 0x220) = dVar11;
      FUN_0078bbec("/home/runner/work/xochitl/xochitl/src/xofm/libs/peninput/src/peninputhandler.cpp"
                   ,"setLineThickness",0x10c,*puVar3,puVar3[1],param_1 + 0x220);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      iVar7 = 3;
      goto LAB_00446184;
    }
    break;
  case 3:
    iVar7 = *(int *)pQVar8;
    FUN_0012c544(param_1 + 8);
    puVar3 = DAT_004468cc;
    if (iVar7 != *(int *)(param_1 + 0x218)) {
      *(int *)(param_1 + 0x218) = iVar7;
      uStack_50 = *puVar3;
      uStack_4c = puVar3[1];
      iVar5 = FUN_004443b4();
      if (*(char *)(iVar5 + 8) != '\0') {
        iVar5 = FUN_004443b4();
        uStack_28 = *(undefined4 *)(iVar5 + 4);
        pcStack_30 = 
        "/home/runner/work/xochitl/xochitl/src/xofm/libs/peninput/src/peninputhandler.cpp";
        uStack_38 = DAT_004468a8;
        pcStack_2c = "setLineArgbCode";
        QMessageLogger::debug();
        FUN_00813398(&uStack_68,uStack_50,uStack_4c,iVar7);
        QDebug::~QDebug((QDebug *)&uStack_68);
      }
    }
    break;
  case 4:
    iVar7 = *(int *)pQVar8;
    FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
    puVar3 = DAT_004468c8;
    if (iVar7 != *(int *)(param_1 + 0x228)) {
      *(int *)(param_1 + 0x228) = iVar7;
      uStack_80 = *puVar3;
      uStack_7c = puVar3[1];
      uStack_78 = puVar3[2];
      uStack_74 = puVar3[3];
      uStack_70 = puVar3[4];
      uStack_6c = puVar3[5];
      FUN_0078be94("/home/runner/work/xochitl/xochitl/src/xofm/libs/peninput/src/peninputhandler.cpp"
                   ,"setEraserTool",0x125,uStack_80,uStack_7c,param_1 + 0x228);
      pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
      iVar7 = 5;
      goto LAB_00446184;
    }
    break;
  case 5:
    iVar7 = *(int *)pQVar8;
    FUN_0012c544(param_1 + 8);
    puVar2 = DAT_004468c4;
    if (iVar7 == *(int *)(param_1 + 0x22c)) break;
    *(int *)(param_1 + 0x22c) = iVar7;
    uStack_68 = *puVar2;
    pcStack_60 = *(char **)(puVar2 + 1);
    pcStack_5c = *(char **)((int)puVar2 + 0xc);
    uStack_58 = *(undefined4 *)(puVar2 + 2);
    uStack_54 = *(undefined4 *)((int)puVar2 + 0x14);
    FUN_0078bd3c("/home/runner/work/xochitl/xochitl/src/xofm/libs/peninput/src/peninputhandler.cpp",
                 "setEraserColor",0x14b,*(undefined4 *)puVar2,*(undefined4 *)((int)puVar2 + 4),
                 param_1 + 0x22c);
    goto LAB_004466d0;
  case 6:
    dVar11 = *(double *)pQVar8;
    FUN_0012c544(param_1 + 8);
    puVar2 = DAT_004468c0;
    if (dVar11 == *(double *)(param_1 + 0x230)) break;
    *(double *)(param_1 + 0x230) = dVar11;
    uStack_38 = *puVar2;
    pcStack_30 = *(char **)(puVar2 + 1);
    pcStack_2c = *(char **)((int)puVar2 + 0xc);
    uStack_28 = *(undefined4 *)(puVar2 + 2);
    uStack_24 = *(undefined4 *)((int)puVar2 + 0x14);
    FUN_0078bbec("/home/runner/work/xochitl/xochitl/src/xofm/libs/peninput/src/peninputhandler.cpp",
                 "setEraserThickness",0x138,*(undefined4 *)puVar2,*(undefined4 *)((int)puVar2 + 4),
                 param_1 + 0x230);
LAB_004466d0:
    pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
    iVar7 = 6;
LAB_00446184:
    QMetaObject::activate
              (param_1,(QMetaObject *)&PTR_PTR_staticMetaObject_00cce450,iVar7,(void **)0x0);
    return;
  case 7:
    QVar1 = *pQVar8;
    FUN_0012c544((pthread_mutex_t *)(param_1 + 8));
    puVar2 = DAT_004468b4;
    if (param_1[0x238] == QVar1) break;
    param_1[0x238] = QVar1;
    uStack_50 = *(undefined4 *)puVar2;
    uStack_4c = *(undefined4 *)((int)puVar2 + 4);
    uStack_38 = *puVar2;
    pcStack_48 = *(char **)(puVar2 + 1);
    pcStack_44 = *(char **)((int)puVar2 + 0xc);
    uStack_40 = *(undefined4 *)(puVar2 + 2);
    uStack_3c = *(undefined4 *)((int)puVar2 + 0x14);
    pcStack_30 = pcStack_48;
    pcStack_2c = pcStack_44;
    uStack_28 = uStack_40;
    uStack_24 = uStack_3c;
    iVar7 = FUN_004443b4();
    if (*(char *)(iVar7 + 8) != '\0') {
      iVar7 = FUN_004443b4();
      uStack_58 = *(undefined4 *)(iVar7 + 4);
      pcStack_60 = 
      "/home/runner/work/xochitl/xochitl/src/xofm/libs/peninput/src/peninputhandler.cpp";
      uStack_68 = DAT_004468a0;
      pcStack_5c = "setRightHandMode";
      QMessageLogger::debug();
      FUN_0082b214(&uStack_80,(void *)uStack_38,uStack_38._4_4_,param_1[0x238]);
      QDebug::~QDebug((QDebug *)&uStack_80);
    }
    pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
LAB_004461a4:
    iVar7 = 8;
    goto LAB_00446184;
  default:
switchD_00445ffc_default:
    return;
  }
  pthread_mutex_unlock((pthread_mutex_t *)(param_1 + 8));
  return;
}

