
undefined8 *
FUN_00aa6990(undefined8 *param_1,int param_2,int param_3,int param_4,int param_5,int param_6)

{
  bool bVar1;
  float fVar2;
  float fVar3;
  undefined2 uVar4;
  char cVar5;
  QTextStream *pQVar6;
  int iVar7;
  char *pcVar8;
  void *__s;
  undefined4 *puVar9;
  char *pcVar10;
  undefined4 uVar11;
  undefined4 uVar12;
  int *piVar13;
  int iVar14;
  int iVar15;
  undefined4 uVar16;
  undefined4 uVar17;
  undefined4 uVar18;
  undefined4 uVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  longlong lVar23;
  undefined8 uVar24;
  undefined4 in_stack_fffffef8;
  undefined *puVar25;
  char *in_stack_fffffefc;
  char local_f4;
  QTextStream *local_f0;
  QMetaObject local_ec [4];
  QTextStream *local_e8;
  QTextStream *local_e4;
  undefined8 local_e0;
  undefined8 local_d8;
  QTextStream *local_d0;
  char local_cc;
  int *local_c8;
  char *pcStack_c4;
  QTextStream *local_c0;
  undefined8 local_b8;
  undefined8 local_b0;
  undefined4 local_a8;
  undefined8 local_a0;
  undefined8 local_98;
  undefined4 local_90;
  char *local_88;
  char *pcStack_84;
  undefined4 local_80;
  int *local_7c;
  char *pcStack_78;
  QTextStream *local_74;
  undefined4 local_70;
  undefined4 uStack_6c;
  QTextStream *local_68;
  undefined4 local_60;
  undefined4 uStack_5c;
  undefined4 uStack_58;
  undefined4 uStack_54;
  undefined4 local_50;
  undefined4 uStack_4c;
  undefined4 uStack_48;
  undefined4 uStack_44;
  
  QMetaObject::indexOfEnumerator("");
  QMetaObject::enumerator((int)&local_e0);
  QMetaObject::indexOfEnumerator("");
  QMetaObject::enumerator((int)&local_d8);
  memset(&pcStack_84,0,0x44);
  local_88 = &DAT_00000009;
  local_70 = 0;
  uStack_6c = 0x3ff00000;
  local_98 = 0xaa26b000aa2708;
  local_80 = 0xff000000;
  local_a0 = local_e0;
  FUN_00aa673c(&local_b8,param_2,&local_a0);
  if ((code *)local_98 != (code *)0x0) {
    (*(code *)local_98)(&local_a0,&local_a0,3);
  }
  if (local_b8._4_1_ == '\0') {
    iVar7 = FUN_00a602bc();
    if (*(char *)(iVar7 + 9) != '\0') {
      local_90 = *(undefined4 *)(iVar7 + 4);
      local_a0 = DAT_00aa8438;
      local_98 = 0;
      QMessageLogger::warning();
      *(undefined1 *)(local_c8 + 7) = 0;
      uVar12 = FUN_0012c8f4(&local_c8,"Failed to read a valid line tool in (line ");
      uVar12 = FUN_0083e1c0(uVar12,param_4);
      uVar12 = FUN_0012c8f4(uVar12,", layer ");
      uVar12 = FUN_0083e1c0(uVar12,param_5);
      FUN_0012c8f4(uVar12,")");
LAB_00aa6bb0:
      QDebug::~QDebug((QDebug *)&local_c8);
    }
  }
  else {
    FUN_00b5f554(&local_88,(int *)local_b8);
    local_a0 = local_d8;
    local_98 = 0xaa26b000aa2708;
    FUN_00aa673c(&local_b8,param_2,&local_a0);
    if ((code *)local_98 != (code *)0x0) {
      (*(code *)local_98)(&local_a0,&local_a0,3);
    }
    if (local_b8._4_1_ == '\0') {
      iVar7 = FUN_00a602bc();
      if (*(char *)(iVar7 + 9) != '\0') {
        local_90 = *(undefined4 *)(iVar7 + 4);
        local_a0 = DAT_00aa6e68;
        local_98 = 0;
        QMessageLogger::warning();
        *(undefined1 *)(local_c8 + 7) = 0;
        uVar12 = FUN_0012c8f4(&local_c8,"Failed to read a valid line color in (line ");
        uVar12 = FUN_0083e1c0(uVar12,param_4);
        uVar12 = FUN_0012c8f4(uVar12,", layer ");
        uVar12 = FUN_0083e1c0(uVar12,param_5);
        FUN_0012c8f4(uVar12,")");
        goto LAB_00aa6bb0;
      }
    }
    else {
      pcStack_84 = (char *)(int *)local_b8;
      iVar15 = param_2 + 4;
      local_b8 = 0;
      local_b0 = 0xaa263800aa2650;
      iVar7 = (**(code **)(**(int **)(param_2 + 0xd8) + 0x48))();
      if (iVar7 == 0) {
        lVar23 = QIODevice::read(*(char **)(param_2 + 0xd8),
                                 CONCAT44(in_stack_fffffefc,in_stack_fffffef8));
        if (lVar23 != 8) goto LAB_00aa6da8;
        local_a0 = CONCAT44(pcStack_c4,local_c8);
        if ((code *)local_b0 == (code *)0x0) {
                    /* WARNING: Subroutine does not return */
          std::__throw_bad_function_call();
        }
        iVar7 = (*local_b0._4_4_)(&local_b8,&local_a0);
        piVar13 = local_c8;
        if (iVar7 == 0) {
          iVar7 = FUN_00a602bc();
          if (*(char *)(iVar7 + 9) != '\0') {
            local_90 = *(undefined4 *)(iVar7 + 4);
            local_a0 = DAT_00aa8440;
            local_98 = 0;
            QMessageLogger::warning();
            local_d0[0x1c] = (QTextStream)0x0;
            puVar9 = (undefined4 *)FUN_0012c8f4((QDebug *)&local_d0,"item ");
            QTextStream::operator<<
                      ((QTextStream *)*puVar9,(double)CONCAT44(in_stack_fffffefc,in_stack_fffffef8))
            ;
            if (((QTextStream *)*puVar9)[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<((QTextStream *)*puVar9,' ');
            }
            uVar12 = FUN_0012c8f4(puVar9," (@ pos=");
            uVar11 = FUN_00a70c8c(iVar15);
            uVar12 = FUN_0035b0a8(uVar12,uVar11);
            FUN_0012c8f4(uVar12,") falls outside the valid range");
            QDebug::~QDebug((QDebug *)&local_d0);
          }
          FUN_00aa4a0c((QDebug *)&local_c8,8);
          goto LAB_00aa6dc4;
        }
        if ((code *)local_b0 != (code *)0x0) {
          (*(code *)local_b0)(&local_b8,&local_b8,3);
        }
        FUN_00b5f57c(piVar13,&local_88);
        if (param_3 < 5) {
LAB_00aa6eec:
          iVar7 = FUN_00a602bc();
          if (*(char *)(iVar7 + 8) != '\0') {
            local_a8 = *(undefined4 *)(iVar7 + 4);
            local_b8 = DAT_00aa79f0;
            local_b0 = 0;
            QMessageLogger::debug();
            pQVar6 = local_f0;
            local_f0[0x1c] = (QTextStream)0x0;
            pcStack_c4 = "Next line #";
            local_c8 = (int *)0xb;
            QString::fromUtf8(&local_a0,0xb,"Next line #");
            QTextStream::operator<<(pQVar6,(QString *)&local_a0);
            if ((int *)local_a0 != (int *)0x0) {
              DataMemoryBarrier(0xb);
              do {
                iVar7 = *(int *)local_a0;
                bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
              } while (!bVar1);
              *(int *)local_a0 = iVar7 + -1;
              DataMemoryBarrier(0xb);
              if (iVar7 + -1 == 0) {
                free((int *)local_a0);
              }
            }
            if (local_f0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_f0,' ');
            }
            QTextStream::operator<<(local_f0,param_4);
            if (local_f0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_f0,' ');
            }
            pQVar6 = local_f0;
            pcStack_c4 = " (layer ";
            local_c8 = (int *)0x8;
            QString::fromUtf8(&local_a0,8," (layer ");
            QTextStream::operator<<(pQVar6,(QString *)&local_a0);
            if ((int *)local_a0 != (int *)0x0) {
              DataMemoryBarrier(0xb);
              do {
                iVar7 = *(int *)local_a0;
                bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
              } while (!bVar1);
              *(int *)local_a0 = iVar7 + -1;
              DataMemoryBarrier(0xb);
              if (iVar7 + -1 == 0) {
                free((int *)local_a0);
              }
            }
            if (local_f0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_f0,' ');
            }
            QTextStream::operator<<(local_f0,param_5);
            if (local_f0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_f0,' ');
            }
            pQVar6 = local_f0;
            pcStack_c4 = ", pos=";
            local_c8 = (int *)0x6;
            QString::fromUtf8(&local_a0,6,", pos=");
            QTextStream::operator<<(pQVar6,(QString *)&local_a0);
            if ((int *)local_a0 != (int *)0x0) {
              DataMemoryBarrier(0xb);
              do {
                iVar7 = *(int *)local_a0;
                bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
              } while (!bVar1);
              *(int *)local_a0 = iVar7 + -1;
              DataMemoryBarrier(0xb);
              if (iVar7 + -1 == 0) {
                free((int *)local_a0);
              }
            }
            if (local_f0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_f0,' ');
            }
            lVar23 = (**(code **)(**(int **)(param_2 + 0xd8) + 0x3c))();
            if (lVar23 < 0) {
              local_a0 = CONCAT44(local_a0._4_4_,&local_98);
              pcVar10 = (char *)operator_new(0x18);
              local_98 = CONCAT44(local_98._4_4_,0x17);
              local_a0 = CONCAT44(0x17,pcVar10);
              pcVar10[0x17] = '\0';
              uVar16 = s_Fatal_error_in_position_010ae358._8_4_;
              uVar11 = s_Fatal_error_in_position_010ae358._4_4_;
              uVar12 = s_Fatal_error_in_position_010ae358._0_4_;
              *(undefined4 *)(pcVar10 + 0xc) = s_Fatal_error_in_position_010ae358._12_4_;
              uVar4 = s_Fatal_error_in_position_010ae358._20_2_;
              *(undefined4 *)pcVar10 = uVar12;
              *(undefined2 *)(pcVar10 + 0x14) = uVar4;
              cVar5 = s_Fatal_error_in_position_010ae358[0x16];
              uVar12 = s_Fatal_error_in_position_010ae358._16_4_;
              *(undefined4 *)(pcVar10 + 4) = uVar11;
              *(undefined4 *)(pcVar10 + 0x10) = uVar12;
              *(undefined4 *)(pcVar10 + 8) = uVar16;
              pcVar10[0x16] = cVar5;
              FUN_00a70a30(iVar15,&local_a0);
              goto LAB_00aa7fac;
            }
            QTextStream::operator<<(local_f0,(uint)lVar23);
            if (local_f0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_f0,' ');
            }
            pQVar6 = local_f0;
            pcStack_c4 = "): tool=";
            local_c8 = (int *)0x8;
            QString::fromUtf8(&local_a0,8,"): tool=");
            QTextStream::operator<<(pQVar6,(QString *)&local_a0);
            if ((int *)local_a0 != (int *)0x0) {
              DataMemoryBarrier(0xb);
              do {
                iVar7 = *(int *)local_a0;
                bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
              } while (!bVar1);
              *(int *)local_a0 = iVar7 + -1;
              DataMemoryBarrier(0xb);
              if (iVar7 + -1 == 0) {
                free((int *)local_a0);
              }
            }
            if (local_f0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_f0,' ');
            }
            *(int *)(local_f0 + 0x14) = *(int *)(local_f0 + 0x14) + 1;
            qt_QMetaEnum_debugOperator((QDebug *)&local_e8,0x10ab704011db5b8,local_ec,local_88);
            pQVar6 = local_e8;
            pcStack_c4 = ", color=";
            local_c8 = (int *)0x8;
            QString::fromUtf8(&local_a0,8,", color=");
            QTextStream::operator<<(pQVar6,(QString *)&local_a0);
            if ((int *)local_a0 != (int *)0x0) {
              DataMemoryBarrier(0xb);
              do {
                iVar7 = *(int *)local_a0;
                bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
              } while (!bVar1);
              *(int *)local_a0 = iVar7 + -1;
              DataMemoryBarrier(0xb);
              if (iVar7 + -1 == 0) {
                free((int *)local_a0);
              }
            }
            if (local_e8[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_e8,' ');
            }
            *(int *)(local_e8 + 0x14) = *(int *)(local_e8 + 0x14) + 1;
            puVar25 = &DAT_011db5b8;
            in_stack_fffffefc = "Color";
            local_e4 = local_e8;
            qt_QMetaEnum_debugOperator
                      ((QDebug *)&local_d0,0x10eb0a0011db5b8,(QMetaObject *)&local_e4,pcStack_84);
            pQVar6 = local_d0;
            pcStack_c4 = ", thick=";
            local_c8 = (int *)0x8;
            QString::fromUtf8(&local_a0,8,", thick=");
            QTextStream::operator<<(pQVar6,(QString *)&local_a0);
            if ((int *)local_a0 != (int *)0x0) {
              DataMemoryBarrier(0xb);
              do {
                iVar7 = *(int *)local_a0;
                bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
              } while (!bVar1);
              *(int *)local_a0 = iVar7 + -1;
              DataMemoryBarrier(0xb);
              if (iVar7 + -1 == 0) {
                free((int *)local_a0);
              }
            }
            if (local_d0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_d0,' ');
            }
            QTextStream::operator<<(local_d0,(double)CONCAT44(in_stack_fffffefc,puVar25));
            if (local_d0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_d0,' ');
            }
            pQVar6 = local_d0;
            pcStack_c4 = ", startLen=";
            local_c8 = (int *)&DAT_0000000b;
            QString::fromUtf8(&local_a0,0xb,", startLen=");
            QTextStream::operator<<(pQVar6,(QString *)&local_a0);
            if ((int *)local_a0 != (int *)0x0) {
              DataMemoryBarrier(0xb);
              do {
                iVar7 = *(int *)local_a0;
                bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
              } while (!bVar1);
              *(int *)local_a0 = iVar7 + -1;
              DataMemoryBarrier(0xb);
              if (iVar7 + -1 == 0) {
                free((int *)local_a0);
              }
            }
            if (local_d0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_d0,' ');
            }
            QTextStream::operator<<(local_d0,(float)local_68);
            if (local_d0[0x1c] != (QTextStream)0x0) {
              QTextStream::operator<<(local_d0,' ');
            }
            QDebug::~QDebug((QDebug *)&local_d0);
            QDebug::~QDebug((QDebug *)&local_e4);
            QDebug::~QDebug((QDebug *)&local_e8);
            QDebug::~QDebug((QDebug *)local_ec);
            QDebug::~QDebug((QDebug *)&local_f0);
          }
          local_a0 = DAT_00aa6e60;
          local_98 = 0xaa261800aa26c8;
          FUN_00aa3924(&local_d0,param_2,&local_a0);
          if ((code *)local_98 != (code *)0x0) {
            (*(code *)local_98)(&local_a0,&local_a0,3);
          }
          if (local_cc == '\0') {
            iVar7 = FUN_00a602bc();
            if (*(char *)(iVar7 + 9) != '\0') {
              local_90 = *(undefined4 *)(iVar7 + 4);
              local_a0 = DAT_00aa6e68;
              local_98 = 0;
              QMessageLogger::warning();
              *(undefined1 *)((int)(int *)local_b8 + 0x1c) = 0;
              uVar12 = FUN_0012c8f4(&local_b8,"Invalid number of points in line ");
              uVar12 = FUN_0083e1c0(uVar12,param_4);
              uVar12 = FUN_0012c8f4(uVar12,", layer ");
              FUN_0083e1c0(uVar12,param_5);
              goto LAB_00aa724c;
            }
          }
          else {
            if (local_d0 + param_6 < (QTextStream *)0x724924) {
              iVar7 = FUN_00a602bc();
              if (*(char *)(iVar7 + 8) != '\0') {
                local_a8 = *(undefined4 *)(iVar7 + 4);
                local_b8 = DAT_00aa79f0;
                local_b0 = 0;
                QMessageLogger::debug();
                pQVar6 = local_e4;
                local_e4[0x1c] = (QTextStream)0x0;
                pcStack_c4 = "Line #";
                local_c8 = (int *)0x6;
                QString::fromUtf8(&local_a0,6,"Line #");
                QTextStream::operator<<(pQVar6,(QString *)&local_a0);
                if ((int *)local_a0 != (int *)0x0) {
                  DataMemoryBarrier(0xb);
                  do {
                    iVar7 = *(int *)local_a0;
                    bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
                  } while (!bVar1);
                  *(int *)local_a0 = iVar7 + -1;
                  DataMemoryBarrier(0xb);
                  if (iVar7 + -1 == 0) {
                    free((int *)local_a0);
                  }
                }
                if (local_e4[0x1c] != (QTextStream)0x0) {
                  QTextStream::operator<<(local_e4,' ');
                }
                QTextStream::operator<<(local_e4,param_4);
                if (local_e4[0x1c] != (QTextStream)0x0) {
                  QTextStream::operator<<(local_e4,' ');
                }
                pQVar6 = local_e4;
                pcStack_c4 = " (layer ";
                local_c8 = (int *)0x8;
                QString::fromUtf8(&local_a0,8," (layer ");
                QTextStream::operator<<(pQVar6,(QString *)&local_a0);
                if ((int *)local_a0 != (int *)0x0) {
                  DataMemoryBarrier(0xb);
                  do {
                    iVar7 = *(int *)local_a0;
                    bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
                  } while (!bVar1);
                  *(int *)local_a0 = iVar7 + -1;
                  DataMemoryBarrier(0xb);
                  if (iVar7 + -1 == 0) {
                    free((int *)local_a0);
                  }
                }
                if (local_e4[0x1c] != (QTextStream)0x0) {
                  QTextStream::operator<<(local_e4,' ');
                }
                QTextStream::operator<<(local_e4,param_5);
                if (local_e4[0x1c] != (QTextStream)0x0) {
                  QTextStream::operator<<(local_e4,' ');
                }
                pQVar6 = local_e4;
                pcStack_c4 = ", pos=";
                local_c8 = (int *)0x6;
                QString::fromUtf8(&local_a0,6,", pos=");
                QTextStream::operator<<(pQVar6,(QString *)&local_a0);
                if ((int *)local_a0 != (int *)0x0) {
                  DataMemoryBarrier(0xb);
                  do {
                    iVar7 = *(int *)local_a0;
                    bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
                  } while (!bVar1);
                  *(int *)local_a0 = iVar7 + -1;
                  DataMemoryBarrier(0xb);
                  if (iVar7 + -1 == 0) {
                    free((int *)local_a0);
                  }
                }
                if (local_e4[0x1c] != (QTextStream)0x0) {
                  QTextStream::operator<<(local_e4,' ');
                }
                lVar23 = (**(code **)(**(int **)(param_2 + 0xd8) + 0x3c))();
                if (lVar23 < 0) {
LAB_00aa7fac:
                  local_a0 = CONCAT44(local_a0._4_4_,&local_98);
                  pcVar10 = (char *)operator_new(0x18);
                  local_98 = CONCAT44(local_98._4_4_,0x17);
                  local_a0 = CONCAT44(0x17,pcVar10);
                  pcVar10[0x17] = '\0';
                  uVar16 = s_Fatal_error_in_position_010ae358._8_4_;
                  uVar11 = s_Fatal_error_in_position_010ae358._4_4_;
                  uVar12 = s_Fatal_error_in_position_010ae358._0_4_;
                  *(undefined4 *)(pcVar10 + 0xc) = s_Fatal_error_in_position_010ae358._12_4_;
                  uVar4 = s_Fatal_error_in_position_010ae358._20_2_;
                  *(undefined4 *)pcVar10 = uVar12;
                  *(undefined2 *)(pcVar10 + 0x14) = uVar4;
                  cVar5 = s_Fatal_error_in_position_010ae358[0x16];
                  uVar12 = s_Fatal_error_in_position_010ae358._16_4_;
                  *(undefined4 *)(pcVar10 + 4) = uVar11;
                  *(undefined4 *)(pcVar10 + 0x10) = uVar12;
                  *(undefined4 *)(pcVar10 + 8) = uVar16;
                  pcVar10[0x16] = cVar5;
                  FUN_00a70a30(iVar15,&local_a0);
                  FUN_00088ac8(&local_a0);
                  QDebug::~QDebug((QDebug *)&local_f0);
                  FUN_0014c538(&local_7c);
                    /* WARNING: Subroutine does not return */
                  __cxa_end_cleanup();
                }
                QTextStream::operator<<(local_e4,(uint)lVar23);
                if (local_e4[0x1c] != (QTextStream)0x0) {
                  QTextStream::operator<<(local_e4,' ');
                }
                pQVar6 = local_e4;
                pcStack_c4 = "): ";
                local_c8 = (int *)0x3;
                QString::fromUtf8(&local_a0,3,&DAT_010ad398);
                QTextStream::operator<<(pQVar6,(QString *)&local_a0);
                if ((int *)local_a0 != (int *)0x0) {
                  DataMemoryBarrier(0xb);
                  do {
                    iVar7 = *(int *)local_a0;
                    bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
                  } while (!bVar1);
                  *(int *)local_a0 = iVar7 + -1;
                  DataMemoryBarrier(0xb);
                  if (iVar7 + -1 == 0) {
                    free((int *)local_a0);
                  }
                }
                if (local_e4[0x1c] != (QTextStream)0x0) {
                  QTextStream::operator<<(local_e4,' ');
                }
                QTextStream::operator<<(local_e4,(int)local_d0);
                if (local_e4[0x1c] != (QTextStream)0x0) {
                  QTextStream::operator<<(local_e4,' ');
                }
                pQVar6 = local_e4;
                pcStack_c4 = " point(s)";
                local_c8 = (int *)&DAT_00000009;
                QString::fromUtf8(&local_a0,9," point(s)");
                QTextStream::operator<<(pQVar6,(QString *)&local_a0);
                if ((int *)local_a0 != (int *)0x0) {
                  DataMemoryBarrier(0xb);
                  do {
                    iVar7 = *(int *)local_a0;
                    bVar1 = (bool)hasExclusiveAccess((int *)local_a0);
                  } while (!bVar1);
                  *(int *)local_a0 = iVar7 + -1;
                  DataMemoryBarrier(0xb);
                  if (iVar7 + -1 == 0) {
                    free((int *)local_a0);
                  }
                }
                if (local_e4[0x1c] != (QTextStream)0x0) {
                  QTextStream::operator<<(local_e4,' ');
                }
                QDebug::~QDebug((QDebug *)&local_e4);
              }
              if (local_d0 == (QTextStream *)0x0) {
LAB_00aa75a4:
                *(undefined4 *)(param_1 + 1) = local_80;
                *param_1 = CONCAT44(pcStack_84,local_88);
                *(ulonglong *)((int)param_1 + 0xc) = CONCAT44(pcStack_78,local_7c);
                *(QTextStream **)((int)param_1 + 0x14) = local_74;
                *(QTextStream **)(param_1 + 4) = local_68;
                *(undefined4 *)(param_1 + 3) = local_70;
                *(undefined4 *)((int)param_1 + 0x1c) = uStack_6c;
                *(undefined4 *)(param_1 + 5) = local_60;
                *(undefined4 *)((int)param_1 + 0x2c) = uStack_5c;
                *(undefined4 *)(param_1 + 6) = uStack_58;
                *(undefined4 *)((int)param_1 + 0x34) = uStack_54;
                *(undefined4 *)(param_1 + 7) = local_50;
                *(undefined4 *)((int)param_1 + 0x3c) = uStack_4c;
                *(undefined4 *)(param_1 + 8) = uStack_48;
                *(undefined4 *)((int)param_1 + 0x44) = uStack_44;
                *(undefined1 *)(param_1 + 9) = 1;
                return param_1;
              }
              pcStack_c4 = (char *)QArrayData::allocate(&local_a0,0xe,8,local_d0,1);
              local_c8 = (int *)local_a0;
              pcVar10 = pcStack_c4;
              do {
                pcVar10[8] = '\0';
                pcVar10[9] = '\0';
                pcVar10[10] = '\0';
                pcVar10[0xb] = '\0';
                pcVar8 = pcVar10 + 0xe;
                pcVar10[0xc] = '\0';
                pcVar10[0xd] = '\0';
                pcVar10[0] = '\0';
                pcVar10[1] = '\0';
                pcVar10[2] = -0x80;
                pcVar10[3] = -0x41;
                pcVar10[4] = '\0';
                pcVar10[5] = '\0';
                pcVar10[6] = -0x80;
                pcVar10[7] = -0x41;
                pcVar10 = pcVar8;
              } while (pcVar8 != pcStack_c4 + (int)local_d0 * 0xe);
              local_c0 = local_d0;
              uVar12 = 1;
              __s = (void *)QArrayData::allocate(&local_a0,4,8,(int)local_d0 * 6);
              local_b0 = CONCAT44(local_b0._4_4_,(int)local_d0 * 6);
              piVar13 = (int *)local_a0;
              local_b8 = CONCAT44(__s,(int *)local_a0);
              if ((int)local_d0 * 0x18 != 0) {
                memset(__s,0,(int)local_d0 * 0x18);
              }
              if ((piVar13 == (int *)0x0) || (1 < *piVar13)) {
                FUN_005cebec(&local_b8,0,0);
              }
              iVar7 = (**(code **)(**(int **)(param_2 + 0xd8) + 0x48))();
              if (iVar7 == 0) {
                lVar23 = QIODevice::read(*(char **)(param_2 + 0xd8),
                                         CONCAT44(in_stack_fffffefc,uVar12));
                fVar3 = DAT_00aa7604;
                fVar2 = DAT_00aa7600;
                if ((longlong)(int)local_d0 * 0x18 == lVar23) {
                  if (0 < (int)local_c0) {
                    iVar7 = 0x14;
                    iVar15 = 0;
                    do {
                      if (((int *)local_b8 == (int *)0x0) || (1 < *(int *)local_b8)) {
                        FUN_005cebec(&local_b8,0,0);
                      }
                      uVar12 = *(undefined4 *)(iVar15 * 0x18 + local_b8._4_4_);
                      if (((int *)local_b8 == (int *)0x0) ||
                         (piVar13 = (int *)local_b8, 1 < *(int *)local_b8)) {
                        FUN_005cebec(&local_b8,0,0);
                        piVar13 = (int *)local_b8;
                      }
                      uVar11 = *(undefined4 *)(local_b8._4_4_ + iVar7 + -0x10);
                      if ((piVar13 == (int *)0x0) || (iVar14 = local_b8._4_4_, 1 < *piVar13)) {
                        FUN_005cebec(&local_b8,0,0);
                        piVar13 = (int *)local_b8;
                        iVar14 = local_b8._4_4_;
                      }
                      fVar22 = *(float *)(iVar14 + iVar7 + -0xc);
                      if ((piVar13 == (int *)0x0) || (1 < *piVar13)) {
                        FUN_005cebec(&local_b8,0,0);
                        piVar13 = (int *)local_b8;
                        iVar14 = local_b8._4_4_;
                      }
                      fVar20 = *(float *)(iVar14 + iVar7 + -8);
                      if ((piVar13 == (int *)0x0) || (1 < *piVar13)) {
                        FUN_005cebec(&local_b8,0,0);
                        piVar13 = (int *)local_b8;
                        iVar14 = local_b8._4_4_;
                      }
                      fVar21 = *(float *)(iVar14 + iVar7 + -4);
                      if ((piVar13 == (int *)0x0) || (1 < *piVar13)) {
                        FUN_005cebec(&local_b8,0,0);
                        iVar14 = local_b8._4_4_;
                      }
                      fVar22 = roundf(fVar22 * 4.0);
                      uVar17 = VectorFloatToUnsigned(fVar22,3);
                      fVar22 = roundf(fVar21 * 4.0);
                      uVar18 = VectorFloatToUnsigned(fVar22,3);
                      fVar22 = roundf((fVar20 * fVar2) / fVar3);
                      uVar16 = VectorFloatToUnsigned(fVar22,3);
                      fVar22 = roundf(*(float *)(iVar14 + iVar7) * fVar2);
                      uVar19 = VectorFloatToUnsigned(fVar22,3);
                      local_f4 = (char)uVar16;
                      cVar5 = local_f4;
                      local_f4 = (char)uVar19;
                      if ((local_c8 == (int *)0x0) || (1 < *local_c8)) {
                        FUN_0043865c((QDebug *)&local_c8,0,0);
                      }
                      iVar14 = iVar15 * 0xe;
                      iVar15 = iVar15 + 1;
                      *(undefined4 *)(pcStack_c4 + iVar14) = uVar12;
                      iVar7 = iVar7 + 0x18;
                      *(short *)(pcStack_c4 + iVar14 + 8) = (short)uVar17;
                      pcStack_c4[iVar14 + 0xc] = cVar5;
                      pcStack_c4[iVar14 + 0xd] = local_f4;
                      *(undefined4 *)(pcStack_c4 + iVar14 + 4) = uVar11;
                      *(short *)(pcStack_c4 + iVar14 + 10) = (short)uVar18;
                    } while (iVar15 < (int)local_c0);
                  }
                  piVar13 = local_7c;
                  if (local_c8 != (int *)0x0) {
                    DataMemoryBarrier(0xb);
                    do {
                      bVar1 = (bool)hasExclusiveAccess(local_c8);
                    } while (!bVar1);
                    *local_c8 = *local_c8 + 1;
                    DataMemoryBarrier(0xb);
                  }
                  pcStack_78 = pcStack_c4;
                  local_74 = local_c0;
                  local_7c = local_c8;
                  if (piVar13 != (int *)0x0) {
                    DataMemoryBarrier(0xb);
                    do {
                      iVar7 = *piVar13;
                      bVar1 = (bool)hasExclusiveAccess(piVar13);
                    } while (!bVar1);
                    *piVar13 = iVar7 + -1;
                    DataMemoryBarrier(0xb);
                    if (iVar7 + -1 == 0) {
                      free(piVar13);
                    }
                  }
                  FUN_00b5f538(&local_88);
                  if ((int *)local_b8 != (int *)0x0) {
                    DataMemoryBarrier(0xb);
                    do {
                      iVar7 = *(int *)local_b8;
                      bVar1 = (bool)hasExclusiveAccess((int *)local_b8);
                    } while (!bVar1);
                    *(int *)local_b8 = iVar7 + -1;
                    DataMemoryBarrier(0xb);
                    if (iVar7 + -1 == 0) {
                      free((int *)local_b8);
                    }
                  }
                  if (local_c8 != (int *)0x0) {
                    DataMemoryBarrier(0xb);
                    do {
                      iVar7 = *local_c8;
                      bVar1 = (bool)hasExclusiveAccess(local_c8);
                    } while (!bVar1);
                    *local_c8 = iVar7 + -1;
                    DataMemoryBarrier(0xb);
                    if (iVar7 + -1 == 0) {
                      free(local_c8);
                    }
                  }
                  goto LAB_00aa75a4;
                }
              }
              else {
                if (*(int *)(param_2 + 4) < 1) {
                  *(undefined4 *)(param_2 + 4) = 1;
                }
                lVar23 = 0;
              }
              iVar7 = FUN_00a602bc();
              if (*(char *)(iVar7 + 9) != '\0') {
                local_90 = *(undefined4 *)(iVar7 + 4);
                local_a0 = DAT_00aa8438;
                local_98 = 0;
                QMessageLogger::warning();
                local_e4[0x1c] = (QTextStream)0x0;
                uVar12 = FUN_0012c8f4((QDebug *)&local_e4,"Failed to read ");
                uVar12 = FUN_0035b0a8(uVar12,(int)(code *)local_b0 << 2);
                uVar24 = FUN_0012c8f4(uVar12," byte(s) (read ");
                uVar12 = FUN_0040d8c4((int)uVar24,(int)((ulonglong)uVar24 >> 0x20),(int)lVar23,
                                      (int)((ulonglong)lVar23 >> 0x20));
                uVar12 = FUN_0012c8f4(uVar12," byte(s) @ pos=");
                uVar11 = FUN_00a70c8c(iVar15);
                uVar12 = FUN_0035b0a8(uVar12,uVar11);
                FUN_0012c8f4(uVar12,")");
                QDebug::~QDebug((QDebug *)&local_e4);
              }
              *(undefined1 *)(param_1 + 9) = 0;
              if ((int *)local_b8 != (int *)0x0) {
                DataMemoryBarrier(0xb);
                do {
                  iVar7 = *(int *)local_b8;
                  bVar1 = (bool)hasExclusiveAccess((int *)local_b8);
                } while (!bVar1);
                *(int *)local_b8 = iVar7 + -1;
                DataMemoryBarrier(0xb);
                if (iVar7 + -1 == 0) {
                  free((int *)local_b8);
                }
              }
              if (local_c8 != (int *)0x0) {
                DataMemoryBarrier(0xb);
                do {
                  iVar7 = *local_c8;
                  bVar1 = (bool)hasExclusiveAccess(local_c8);
                } while (!bVar1);
                *local_c8 = iVar7 + -1;
                DataMemoryBarrier(0xb);
                if (iVar7 + -1 == 0) {
                  free(local_c8);
                }
              }
              goto LAB_00aa6a9c;
            }
            iVar7 = FUN_00a602bc();
            if (*(char *)(iVar7 + 9) != '\0') {
              local_90 = *(undefined4 *)(iVar7 + 4);
              local_a0 = DAT_00aa6e68;
              local_98 = 0;
              QMessageLogger::warning();
              *(undefined1 *)((int)(int *)local_b8 + 0x1c) = 0;
              uVar12 = FUN_0012c8f4(&local_b8,"Too many points in total: total so far=");
              uVar12 = FUN_0035b0a8(uVar12,param_6);
              uVar12 = FUN_0012c8f4(uVar12,", this line=");
              uVar12 = FUN_0083e1c0(uVar12,local_d0);
              puVar9 = (undefined4 *)FUN_0012c8f4(uVar12,&DAT_010af098);
              QTextStream::operator<<((QTextStream *)*puVar9,0x724924);
              if (((QTextStream *)*puVar9)[0x1c] != (QTextStream)0x0) {
                QTextStream::operator<<((QTextStream *)*puVar9,' ');
              }
              goto LAB_00aa724c;
            }
          }
          goto LAB_00aa6a94;
        }
        local_b8 = 0;
        local_b0 = 0xaa267c00aa2684;
        iVar7 = (**(code **)(**(int **)(param_2 + 0xd8) + 0x48))();
        if (iVar7 == 0) {
          lVar23 = QIODevice::read(*(char **)(param_2 + 0xd8),
                                   CONCAT44(in_stack_fffffefc,in_stack_fffffef8));
          if (lVar23 != 4) goto LAB_00aa6cdc;
          local_a0 = CONCAT44(local_a0._4_4_,local_d0);
          if ((code *)local_b0 == (code *)0x0) {
                    /* WARNING: Subroutine does not return */
            std::__throw_bad_function_call();
          }
          iVar7 = (*local_b0._4_4_)(&local_b8,&local_a0);
          pQVar6 = local_d0;
          if (iVar7 != 0) {
            if ((code *)local_b0 != (code *)0x0) {
              (*(code *)local_b0)(&local_b8,&local_b8,3);
            }
            local_68 = pQVar6;
            goto LAB_00aa6eec;
          }
          iVar7 = FUN_00a602bc();
          if (*(char *)(iVar7 + 9) != '\0') {
            local_90 = *(undefined4 *)(iVar7 + 4);
            local_a0 = DAT_00aa8438;
            local_98 = 0;
            QMessageLogger::warning();
            *(undefined1 *)(local_c8 + 7) = 0;
            FUN_0012c8f4((QDebug *)&local_c8,"item ");
            uVar12 = FUN_00aaa6d0(local_d0);
            uVar12 = FUN_0012c8f4(uVar12," (@ pos=");
            uVar11 = FUN_00a70c8c(iVar15);
            uVar12 = FUN_0035b0a8(uVar12,uVar11);
            FUN_0012c8f4(uVar12,") falls outside the valid range");
            QDebug::~QDebug((QDebug *)&local_c8);
          }
          FUN_00aa3b78(&local_d0,4);
        }
        else {
          lVar23 = 0;
          if (*(int *)(param_2 + 4) < 1) {
            *(undefined4 *)(param_2 + 4) = 1;
            lVar23 = 0;
          }
LAB_00aa6cdc:
          iVar7 = FUN_00a602bc();
          if (*(char *)(iVar7 + 9) != '\0') {
            local_90 = *(undefined4 *)(iVar7 + 4);
            local_a0 = DAT_00aa8438;
            local_98 = 0;
            QMessageLogger::warning();
            *(undefined1 *)(local_c8 + 7) = 0;
            uVar12 = FUN_0012c8f4((QDebug *)&local_c8,"Failed to read ");
            uVar12 = FUN_0035b0a8(uVar12,4);
            uVar24 = FUN_0012c8f4(uVar12," byte(s) (read ");
            uVar12 = FUN_0040d8c4((int)uVar24,(int)((ulonglong)uVar24 >> 0x20),(int)lVar23,
                                  (int)((ulonglong)lVar23 >> 0x20));
            uVar12 = FUN_0012c8f4(uVar12," byte(s) @ pos=");
            uVar11 = FUN_00a70c8c(iVar15);
            uVar12 = FUN_0035b0a8(uVar12,uVar11);
            FUN_0012c8f4(uVar12,")");
            QDebug::~QDebug((QDebug *)&local_c8);
          }
          FUN_00aa3b78(&local_d0,(int)lVar23);
        }
        if ((code *)local_b0 != (code *)0x0) {
          (*(code *)local_b0)(&local_b8,&local_b8,3);
        }
        iVar7 = FUN_00a602bc();
        if (*(char *)(iVar7 + 9) == '\0') goto LAB_00aa6a94;
        local_90 = *(undefined4 *)(iVar7 + 4);
        local_a0 = DAT_00aa6e68;
        local_98 = 0;
        QMessageLogger::warning();
        *(undefined1 *)((int)(int *)local_b8 + 0x1c) = 0;
        uVar12 = FUN_0012c8f4(&local_b8,"Failed to read a valid starting length in (line ");
        uVar12 = FUN_0083e1c0(uVar12,param_4);
        uVar12 = FUN_0012c8f4(uVar12,", layer ");
        uVar12 = FUN_0083e1c0(uVar12,param_5);
        FUN_0012c8f4(uVar12,")");
      }
      else {
        lVar23 = 0;
        if (*(int *)(param_2 + 4) < 1) {
          *(undefined4 *)(param_2 + 4) = 1;
          lVar23 = 0;
        }
LAB_00aa6da8:
        iVar7 = FUN_00a602bc();
        if (*(char *)(iVar7 + 9) != '\0') {
          local_90 = *(undefined4 *)(iVar7 + 4);
          local_a0 = DAT_00aa8438;
          local_98 = 0;
          QMessageLogger::warning();
          local_d0[0x1c] = (QTextStream)0x0;
          uVar12 = FUN_0012c8f4((QDebug *)&local_d0,"Failed to read ");
          uVar12 = FUN_0035b0a8(uVar12,8);
          uVar24 = FUN_0012c8f4(uVar12," byte(s) (read ");
          uVar12 = FUN_0040d8c4((int)uVar24,(int)((ulonglong)uVar24 >> 0x20),(int)lVar23,
                                (int)((ulonglong)lVar23 >> 0x20));
          uVar12 = FUN_0012c8f4(uVar12," byte(s) @ pos=");
          uVar11 = FUN_00a70c8c(iVar15);
          uVar12 = FUN_0035b0a8(uVar12,uVar11);
          FUN_0012c8f4(uVar12,")");
          QDebug::~QDebug((QDebug *)&local_d0);
        }
        FUN_00aa4a0c(&local_c8,(int)lVar23);
LAB_00aa6dc4:
        if ((code *)local_b0 != (code *)0x0) {
          (*(code *)local_b0)(&local_b8,&local_b8,3);
        }
        iVar7 = FUN_00a602bc();
        if (*(char *)(iVar7 + 9) == '\0') goto LAB_00aa6a94;
        local_90 = *(undefined4 *)(iVar7 + 4);
        local_a0 = DAT_00aa6e68;
        local_98 = 0;
        QMessageLogger::warning();
        *(undefined1 *)((int)(int *)local_b8 + 0x1c) = 0;
        uVar12 = FUN_0012c8f4(&local_b8,"Failed to read a valid thickness in (line ");
        uVar12 = FUN_0083e1c0(uVar12,param_4);
        uVar12 = FUN_0012c8f4(uVar12,", layer ");
        uVar12 = FUN_0083e1c0(uVar12,param_5);
        FUN_0012c8f4(uVar12,")");
      }
LAB_00aa724c:
      QDebug::~QDebug((QDebug *)&local_b8);
    }
  }
LAB_00aa6a94:
  *(undefined1 *)(param_1 + 9) = 0;
LAB_00aa6a9c:
  if (local_7c != (int *)0x0) {
    DataMemoryBarrier(0xb);
    do {
      iVar7 = *local_7c;
      bVar1 = (bool)hasExclusiveAccess(local_7c);
    } while (!bVar1);
    *local_7c = iVar7 + -1;
    DataMemoryBarrier(0xb);
    if (iVar7 + -1 == 0) {
      free(local_7c);
    }
  }
  return param_1;
}

