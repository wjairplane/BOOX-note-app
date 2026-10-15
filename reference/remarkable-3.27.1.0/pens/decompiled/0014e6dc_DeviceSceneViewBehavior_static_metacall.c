
void FUN_0014e6dc(undefined4 param_1,int param_2,uint param_3,int *param_4)

{
  byte bVar1;
  bool bVar2;
  int iVar3;
  undefined1 *puVar4;
  undefined4 *puVar5;
  bool bVar6;
  undefined4 uVar7;
  int iVar8;
  int iVar9;
  undefined4 local_48;
  undefined1 auStack_44 [12];
  QVariant aQStack_38 [28];
  
  if (param_2 == 0) {
    if (param_3 == 0) {
      puVar5 = (undefined4 *)param_4[1];
      uVar7 = *puVar5;
      iVar3 = FUN_00b5f448(uVar7);
      if (iVar3 == 0) {
        iVar3 = FUN_00b5f434(uVar7);
      }
      iVar8 = puVar5[1];
      iVar9 = puVar5[2];
      bVar1 = FUN_00b5f458(*puVar5);
      if (iVar8 == 0) {
        bVar6 = (bool)(bVar1 & 1);
      }
      else {
        bVar6 = false;
      }
      if (bVar6 == false) {
        if (iVar8 == 9) {
          bVar6 = iVar9 != -0x1000000 && iVar9 != -1;
        }
        else if (iVar8 - 1U < 0xd) {
          bVar6 = *(int *)(&DAT_00ccc010 + (iVar8 - 1U) * 4) != -0x1000000 &&
                  *(int *)(&DAT_00ccc010 + (iVar8 - 1U) * 4) != -1;
        }
      }
      local_48 = 0;
      bVar2 = (bool)FUN_00b5f1e4(puVar5);
      QVariant::QVariant(aQStack_38,bVar2);
      FUN_0012c464(auStack_44,"addToTiles");
      uVar7 = FUN_0014e290(&local_48,auStack_44);
      FUN_0014bdd0(uVar7,aQStack_38);
      FUN_00088fa0(auStack_44);
      QVariant::~QVariant(aQStack_38);
      QVariant::QVariant(aQStack_38,SUB41(iVar3,0));
      FUN_0012c464(auStack_44,"markViewportDirty");
      uVar7 = FUN_0014e290(&local_48,auStack_44);
      FUN_0014bdd0(uVar7,aQStack_38);
      FUN_00088fa0(auStack_44);
      QVariant::~QVariant(aQStack_38);
      QVariant::QVariant(aQStack_38,bVar6);
      FUN_0012c464(auStack_44,"delayedRefresh");
      uVar7 = FUN_0014e290(&local_48,auStack_44);
      FUN_0014bdd0(uVar7,aQStack_38);
      FUN_00088fa0(auStack_44);
      QVariant::~QVariant(aQStack_38);
      QVariant::QVariant(aQStack_38,(QMap *)&local_48);
      FUN_0014dcf8(&local_48);
      if (*param_4 != 0) {
        FUN_0014bdd0(*param_4,aQStack_38);
      }
      QVariant::~QVariant(aQStack_38);
      return;
    }
    if (param_3 != 1) {
      return;
    }
    puVar4 = (undefined1 *)*param_4;
    if (puVar4 == (undefined1 *)0x0) {
      return;
    }
  }
  else {
    if (param_2 == 7) {
      if ((param_3 == 1) && (*(int *)param_4[1] == 0)) {
        *(undefined4 *)*param_4 = DAT_0014e980;
        return;
      }
      *(undefined4 *)*param_4 = 0;
      return;
    }
    if (param_2 != 1) {
      return;
    }
    puVar4 = (undefined1 *)*param_4;
    if (param_3 != 2) {
      if ((int)param_3 < 3) {
        if (1 < param_3) {
          return;
        }
      }
      else if (param_3 != 3) {
        return;
      }
      *puVar4 = 0;
      return;
    }
  }
  *puVar4 = (char)param_2;
  return;
}

