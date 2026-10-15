
uint FUN_0014cea0(int *param_1,undefined4 param_2,int param_3,uint param_4)

{
  uint uVar1;
  int iVar2;
  uint uVar3;
  uint uVar4;
  
  uVar1 = FUN_00b5f458(param_2);
  if (param_3 == 0) {
    uVar1 = uVar1 & 1;
  }
  else {
    uVar1 = 0;
  }
  if (uVar1 != 0) {
    uVar1 = 0xffebebeb;
    if (*param_1 != 1) {
      uVar1 = 0xfffefd60;
    }
    return uVar1;
  }
  iVar2 = *param_1;
  if (param_3 == 9) {
    if (iVar2 != 1) {
      return param_4;
    }
  }
  else {
    if (iVar2 == 2) {
      switch(param_3) {
      case 6:
        return 0xff0000ff;
      case 7:
        goto switchD_0014d034_caseD_7;
      default:
switchD_0014d034_caseD_8:
        if (param_3 - 1U < 0xd) {
          return *(uint *)(&DAT_00ccc010 + (param_3 - 1U) * 4);
        }
        return 0xff000000;
      case 10:
        return 0xff00ff00;
      case 0xb:
        return 0xff00ffff;
      case 0xc:
switchD_0014d034_caseD_c:
        return 0xffff00ff;
      case 0xd:
switchD_0014d034_caseD_d:
        return 0xffffff00;
      }
    }
    if (iVar2 == 3) {
      switch(param_3) {
      case 6:
        return 0xff000098;
      case 7:
switchD_0014d034_caseD_7:
        return 0xffff0000;
      default:
        goto switchD_0014d034_caseD_8;
      case 10:
        return 0xff008800;
      case 0xb:
        return 0xff057777;
      case 0xc:
        goto switchD_0014d034_caseD_c;
      case 0xd:
        goto switchD_0014d034_caseD_d;
      }
    }
    if (param_3 - 1U < 0xd) {
      uVar1 = *(uint *)(&DAT_00ccc010 + (param_3 - 1U) * 4);
    }
    else {
      uVar1 = 0xff000000;
    }
    if (iVar2 != 1) {
      return uVar1;
    }
    uVar3 = (uVar1 & 0xff) * 0x1d + ((uVar1 << 8) >> 0x18) * 0x4d + ((uVar1 << 0x10) >> 0x18) * 0x96
    ;
    uVar4 = uVar3 >> 8;
    param_4 = uVar3 & 0xffffff00 | uVar4 | uVar1 & 0xff000000 | uVar4 << 0x10;
  }
  uVar4 = (param_4 & 0xff) * 0x1d +
          ((param_4 << 8) >> 0x18) * 0x4d + ((param_4 << 0x10) >> 0x18) * 0x96;
  uVar1 = uVar4 >> 8;
  uVar4 = uVar4 & 0xffffff00 | uVar1;
  uVar3 = uVar4 | param_4 & 0xff000000 | uVar1 << 0x10;
  uVar4 = (uVar1 & 0xff) * 0x1d + ((uVar3 << 8) >> 0x18) * 0x4d + ((uVar4 << 0x10) >> 0x18) * 0x96;
  uVar1 = uVar4 >> 8;
  return uVar4 & 0xffffff00 | uVar1 | uVar3 & 0xff000000 | uVar1 << 0x10;
}

