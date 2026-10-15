
float FUN_00b5f7fc(float param_1,undefined4 *param_2)

{
  float fVar1;
  
  switch(*param_2) {
  case 0:
  case 1:
    fVar1 = DAT_00b5f8ec;
    break;
  case 2:
  case 0xf:
  case 0x13:
  case 0x14:
    fVar1 = 2.0;
    break;
  case 3:
  case 0x10:
    fVar1 = 20.0;
    break;
  case 4:
  case 7:
  case 8:
  case 0xb:
  case 0x11:
    fVar1 = 3.0;
    break;
  case 5:
  case 0x12:
    fVar1 = 30.0;
    break;
  case 6:
  case 0x16:
    fVar1 = (float)(*(double *)(param_2 + 6) * 10.0);
    break;
  default:
    fVar1 = 1.0;
    break;
  case 10:
  case 0x17:
    fVar1 = 10.0;
    break;
  case 0xc:
    fVar1 = 15.0;
    break;
  case 0xd:
    fVar1 = 4.0;
    break;
  case 0xe:
    fVar1 = 18.0;
    break;
  case 0x15:
    fVar1 = 6.0;
  }
  return (float)*(double *)(param_2 + 6) * fVar1 * param_1 + 2.0;
}

