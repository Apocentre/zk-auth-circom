pragma circom 2.1.6;

include "./bitwise.circom";

template Test() {
  component right_shift = RightShift(8, 2);
  right_shift.num <== 105;
  log("105 >> 2", right_shift.out);

  component left_shift = LeftShift(8, 2);
  left_shift.num <== 105;
  log("105 << 2", left_shift.out);

  component and = LogicalAnd(8);
  and.a <== 5;
  and.b <== 3;
  log("5 & 3 = ", and.out);
}

component main = Test();
