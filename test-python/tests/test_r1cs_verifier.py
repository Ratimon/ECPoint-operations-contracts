import numpy as np
import random
import galois
from py_ecc.bn128 import G1, G2, multiply, neg, pairing


def test_polynomial():

    # Transforming:
    # out = 5*x^3 - 4*y^2*x^2 + 13*x*y^2 + x^2 - 10*y
    # out = 5*v1*x - 4*v1*v2 + 13*x*v2 + v1 - 10*y

    # v1 = x*x
    # v2 = y*y
    # v3 = v1*v2
    # v4 = x*v2
    
    # 4*v3  - 13*v4 - v1 + 10*y + out = 5*v1*x
    # out + 10*y - v1 + 4*v3 - 13*v4  = 5*v1*x

    # Our witness vector is: [1 out x y v1 v2 v3 v4]

    p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    FP = galois.GF(p)

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

    w = FP(np.array([1, 22, 1, 2, 1, 4, 4, 4]))

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

    # A = multiply(G2, 5)
    # B = multiply(G1, 6)
    # C = multiply(G1, 5 * 6)

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


    # print("e w  {}".format( multiply(G2,w[1]) ))

    # print("G1  {}".format(multiply(G1, 4) ))

    vectorized_function = np.vectorize(multiply_G1)

    result = vectorized_function(w)

    print("result  {}".format(result ))

    # e_w = np.array([ multiply(G1, w[0]), multiply(G1, w[1]), multiply(G1, w[2]), multiply(G1, w[3]), multiply(G1, w[4]), multiply(G1, w[5]), multiply(G1, w[6])])
    # e_L = np.dot(L, e_w) 

    # print("e_L  {}".format(e_L ))

    assert False

def test_multiply_witness():
    w = np.array([1, 22, 1, 2, 1, 4, 4, 4])

    print("w  {}".format(w ))
    print("w 0 {}".format(w[0] ))
    print("w 1  {}".format(w[1] ))
    print("encrypted public 1: LHS  {}".format( multiply(G1, int(w[0])) ))
    print("encrypted public 2: LHS  {}".format( multiply(G1, int(w[1]) ) ))
    print("encrypted public 3: LHS  {}".format( multiply(G1, int(w[2]) ) ))
    print("encrypted public 4: LHS  {}".format( multiply(G1, int(w[3]) ) ))
    print("encrypted public 5: LHS  {}".format( multiply(G1, int(w[4]) ) ))
    print("encrypted public 6: LHS  {}".format( multiply(G1, int(w[5]) ) ))
    print("encrypted public 7: LHS  {}".format( multiply(G1, int(w[6]) ) ))
    print("encrypted public 8: LHS  {}".format( multiply(G1, int(w[7]) ) ))

    assert False


def multiply_G1(element):
    return multiply(G1, element)