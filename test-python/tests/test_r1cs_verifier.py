import numpy as np
import random
import galois
from py_ecc.bn128 import G1, G2, multiply,add, neg, pairing


def test_polynomial_transfrom():

    # Transforming:
    # out = 5*x^3 - 4*y^2*x^2 + 13*x*y^2 + x^2 - 10*y
    # out = 5*v1*x - 4*v1*v2 + 13*x*v2 + v1 - 10*y

    # v1 = x*x
    # v2 = y*y
    # v3 = v1*v2
    # v4 = x*v2
    
    # 4*v3  - 13*v4 - v1 + 10*y + out = 5*v1*x
    # out + 10*y - v1 + 4*v3 - 13*v4  = 5*v1*x

    p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    FP = galois.GF(p)

    # Our witness vector is: [1 out x y v1 v2 v3 v4]
    L=  FP(np.array( [[0,0,1,0,0,0,0,0],
                  [0,0,0,1,0,0,0,0],
                  [0,0,0,0,1,0,0,0],
                  [0,0,1,0,0,0,0,0],
                  [0,0,0,0,5,0,0,0]]))
    
    R = FP(np.array([[0,0,1,0,0,0,0,0],
                  [0,0,0,1,0,0,0,0],
                  [0,0,0,0,0,1,0,0],
                  [0,0,0,0,0,1,0,0],
                  [0,0,1,0,0,0,0,0]]))
    
    O = FP(np.array([[0,0,0,0,1,0,0,0],
                  [0,0,0,0,0,1,0,0],
                  [0,0,0,0,0,0,1,0],
                  [0,0,0,0,0,0,0,1],
                  [0,1,0,10,FP(p-1),0,4,FP(p-13)]]))
    
    # pick random values for x and y
    # x = FP(random.randint(1,1000))
    # y = FP(random.randint(1,1000))
    x = FP(1)
    y = FP(2)

    out = 5*x*x*x + FP( p-4 )*y*y*x*x + 13*x*y*y + x*x + FP( p-10 )*y

    v1 = x*x
    v2 = y*y
    v3 = v1*v2
    v4 = x*v2
    out = 5*x*x*x + FP(p-4)*y*y*x*x+ 13*x*y*y + x*x + FP(p-10)*y

    w = FP(np.array([1, out, x, y, v1, v2, v3, v4]))

    print("w =", w)

    print("O =", O)
    print("L =", L)
    print("R =", R)
    
    LwRw = np.multiply(L.dot(w), R.dot(w))
    print("Lw * Rw =", LwRw)
    print("Ow =     ", O.dot(w))

    result = O.dot(w) == np.multiply(L.dot(w),R.dot(w))
    assert result.all(), "result contains an inequality"
    result2 = np.multiply(L.dot(w), R.dot(w)) - O.dot(w) == 0
    assert result2.all(), "system contains an inequality"

    print("G1 {}".format(G1 ))
    print("G2 {}".format(G2 ))

    print("w  {}".format(w ))
    print("w 0 {}".format(w[0] ))
    print("w 1  {}".format(w[1] ))
    print("e w  {}".format( multiply(G1,w[0]) ))
    print("e w 1  {}".format( multiply(G1, int(w[1]) ) ))
    print("e w 2  {}".format( multiply(G1, int(w[2]) ) ))
    print("e w 3  {}".format( multiply(G1, int(w[3]) ) ))
    print("e w 3  {}".format( multiply(G1, int(w[4]) ) ))
    print("w 1 {}".format( w[1] ))

    vectorized_function = np.vectorize(multiply_G1)

    result = vectorized_function(w)

    print("result  {}".format(result ))
    assert False

def multiply_G1(element):
    return multiply(G1, element)

def test_parings():
    w = np.array([1, 22, 1, 2, 1, 4, 4, 4])

    # Our witness vector is: [1 out x y v1 v2 v3 v4]

    print("w  {}".format(w ))
    print("encrypted public 1: 1  {}".format( multiply(G1, int(w[0])) ))
    print("encrypted public 2: out  {}".format( multiply(G1, int(w[1]) ) ))
    print("encrypted public 3: x  {}".format( multiply(G1, int(w[2]) ) ))
    print("encrypted public 4: y  {}".format( multiply(G1, int(w[3]) ) ))
    print("encrypted public 5: v1  {}".format( multiply(G1, int(w[4]) ) ))
    print("encrypted public 6: v2  {}".format( multiply(G1, int(w[5]) ) ))
    print("encrypted public 7: v3  {}".format( multiply(G1, int(w[6]) ) ))
    print("encrypted public 8: v4  {}".format( multiply(G1, int(w[7]) ) ))

    # 5 constraints & parings
    # v1 = x*x
    # v2 = y*y
    # v3 = v1*v2
    # v4 = x*v2
    # out + 10*y - v1 + 4*v3 - 13*v4  = 5*v1*x

    # 1st: x*x - v1 = 0
    # 1st: 1*1 - 1 = 0
    e2_x = multiply(G2, w[2])
    e1_x = multiply(G1, w[2])
    e12_v1 = pairing(G2, multiply(G1, w[4]))

    print("1st: x*x - v1 = 0  {}".format(pairing(e2_x, e1_x) == e12_v1))

    # 2nd: y*y - v2 = 0
    # 2nd: 2*2 - 4 = 0
    e2_y = multiply(G2, w[3])
    e1_y = multiply(G1, w[3])
    e12_v2 = pairing(G2, multiply(G1, w[5]))

    print("2nd: y*y - v2 = 0  {}".format(pairing(e2_y, e1_y) == e12_v2))

    # 3rd: v1*v2 - v3 = 0
    e2_v1 = multiply(G2, w[4])
    e1_v2 = multiply(G1, w[5])
    e12_v3 = pairing(G2, multiply(G1, w[6]))

    print("3rd: v1*v2 - v3 = 0  {}".format(pairing(e2_v1, e1_v2) == e12_v3))

    # 4th: x*v2 - v4 = 0
    e2_x = multiply(G2, w[2])
    e1_v2 = multiply(G1, w[5])
    e12_v4 = pairing(G2, multiply(G1, w[7]))

    print("4th: x*v2 - v4 = 0  {}".format(pairing(e2_x, e1_v2) == e12_v4))

    # 5th: (5*v1)*x - out - 10*y + v1 - 4*v3 + 13*v4 = 0
    #  5*v1*x = out + 10*y - v1 + 4*v3 - 13*v4  = 5*v1*x
    e2_5v1 = multiply(G2, 5*w[4])
    e1_x = multiply(G1, w[2])

    e1_out = multiply(G1, w[1])
    e1_10y = multiply(G1, 10*w[3])
    e1_negate_v1 = neg(multiply(G1, w[4]))
    e1_4v3 = multiply(G1, 4*w[6])
    e1_negate_13v4 = neg(multiply(G1, 13*w[7]))

    RHS_1 = add(e1_out, e1_10y)
    RHS_2 = add(e1_negate_v1, e1_4v3)
    RHS_3 = add(RHS_1, RHS_2)
    RHS_final = add(RHS_3, e1_negate_13v4)

    print("5th: (5*v1)*x - out - 10*y + v1 - 4*v3 + 13*v4 = 0  {}".format(pairing(e2_5v1, e1_x) == pairing(G2, RHS_final)))
    assert False