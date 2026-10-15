
void FUN_00b65034(undefined4 *param_1,float param_2,float param_3,float param_4,float param_5,
                 float param_6,float param_7)

{
  float fVar1;
  float fVar2;
  float *pfVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  undefined8 local_68;
  undefined8 local_60;
  float local_58;
  float local_54;
  float local_50;
  float local_4c;
  float local_48;
  float local_44;
  float local_40;
  float local_3c;
  
  fVar5 = (float)param_1[1];
  if (((((fVar5 == param_2 || fVar5 < param_2 != (NAN(fVar5) || NAN(param_2))) &&
        (fVar5 == param_4 || fVar5 < param_4 != (NAN(fVar5) || NAN(param_4)))) &&
       (fVar5 == param_6 || fVar5 < param_6 != (NAN(fVar5) || NAN(param_6)))) &&
      ((((fVar4 = (float)param_1[2], param_2 <= fVar4 && (param_4 <= fVar4)) &&
        ((param_6 <= fVar4 &&
         ((fVar4 = (float)param_1[3],
          fVar4 == param_3 || fVar4 < param_3 != (NAN(fVar4) || NAN(param_3)) &&
          (fVar4 == param_5 || fVar4 < param_5 != (NAN(fVar4) || NAN(param_5)))))))) &&
       (fVar4 == param_7 || fVar4 < param_7 != (NAN(fVar4) || NAN(param_7)))))) &&
     (((fVar4 = (float)param_1[4], param_3 <= fVar4 && (param_5 <= fVar4)) && (param_7 <= fVar4))))
  {
    local_44 = param_5;
    local_40 = param_6;
    local_3c = param_7;
    local_50 = param_2;
    local_4c = param_3;
    local_48 = param_4;
    (**(code **)(*(int *)*param_1 + 8))
              ((int *)*param_1,param_2,param_3,param_4,param_5,param_6,param_7,0,0,0);
    return;
  }
  local_50 = param_2;
  local_4c = param_3;
  local_48 = param_4;
  local_44 = param_5;
  local_40 = param_6;
  local_3c = param_7;
  fVar4 = param_6;
  fVar7 = param_7;
  if (param_2 == param_4 || param_2 < param_4 != (NAN(param_2) || NAN(param_4))) {
    fVar1 = param_3;
    fVar2 = param_2;
    fVar6 = param_4;
    fVar8 = param_5;
    if (param_2 != param_6 && param_2 < param_6 == (NAN(param_2) || NAN(param_6))) {
      fVar1 = param_7;
      fVar2 = param_6;
      fVar4 = param_2;
      fVar7 = param_3;
    }
LAB_00b651a4:
    param_6 = fVar2;
    param_7 = fVar1;
    param_4 = fVar6;
    param_2 = fVar4;
    param_3 = fVar7;
    param_5 = fVar8;
    if (fVar4 < fVar6) {
      param_4 = fVar4;
      param_2 = fVar6;
      param_3 = fVar8;
      param_5 = fVar7;
    }
  }
  else {
    fVar1 = param_5;
    fVar2 = param_4;
    fVar6 = param_2;
    fVar8 = param_3;
    if (param_4 == param_6 || param_4 < param_6 != (NAN(param_4) || NAN(param_6)))
    goto LAB_00b651a4;
  }
  if (fVar5 < param_6) {
    local_50 = param_6;
    local_4c = param_7;
    local_48 = param_4;
    pfVar3 = &local_50;
    local_44 = param_5;
    local_40 = param_2;
    local_3c = param_3;
  }
  else {
    if (fVar5 < param_4) {
      fVar4 = param_7 + ((fVar5 - param_6) / (param_2 - param_6)) * (param_3 - param_7);
      param_7 = param_7 + ((fVar5 - param_6) / (param_4 - param_6)) * (param_5 - param_7);
      local_68 = CONCAT44(param_7,fVar5);
      local_60 = CONCAT44(fVar4,fVar5);
      local_58 = param_4;
      local_54 = param_5;
      FUN_00b64e80(param_1,fVar5,param_7,fVar5,fVar4,param_4,param_5);
      fVar5 = (float)param_1[1];
      local_68 = CONCAT44(fVar4,fVar5);
      local_60 = CONCAT44(param_5,param_4);
      local_58 = param_2;
      local_54 = param_3;
      goto LAB_00b6525c;
    }
    if (param_2 <= fVar5) {
      return;
    }
    local_54 = param_3;
    local_58 = param_2;
    local_68 = CONCAT44(param_3 + ((fVar5 - param_2) / (param_6 - param_2)) * (param_7 - param_3),
                        fVar5);
    local_60 = CONCAT44(param_3 + ((fVar5 - param_2) / (param_4 - param_2)) * (param_5 - param_3),
                        fVar5);
    pfVar3 = (float *)&local_68;
  }
  fVar5 = *pfVar3;
  fVar4 = pfVar3[1];
  param_4 = pfVar3[2];
LAB_00b6525c:
  FUN_00b64e80(param_1,fVar5,fVar4,param_4);
  return;
}

