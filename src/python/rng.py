#!/usr/bin/env python3

BTN_ORDER_ACC = 'LSUABTDR'
BTN_ORDER_TAS = 'ABSTUDLR'
BTN_ORDER_RNG = 'LBSTUDAR'

BIT_ORDER_BYTE  = '76543210'
BIT_ORDER_FRAME = '02467531'

BITS_PER_BYTE = 8
BYTE_SIZE = 2**BITS_PER_BYTE

def argsort(seq):
    return [i for (v, i) in sorted((v, i) for (i, v) in enumerate(seq))]


def get_mapping(order1, order2):
    assert(len(order1) == len(order2))
    f = argsort(list(order1))
    g = argsort(list(order2))
    return [f[i] for i in argsort(g)]


def as_tas_string(acc_value):
    assert(acc_value < BYTE_SIZE)
    acc_bits = [int(bit) for bit in bin(acc_value + BYTE_SIZE)[-BITS_PER_BYTE:]]
    tas_bits = [acc_bits[i] for i in get_mapping(BTN_ORDER_ACC, BTN_ORDER_TAS)]
    return ''.join(c if b else '-' for b,c in zip(tas_bits, BTN_ORDER_TAS))


def tas_manip(current, desired):
    assert(current < BYTE_SIZE and desired < BYTE_SIZE)
    if desired < current:
        delta = BYTE_SIZE + desired - current
    else:
        delta = desired - current

    return as_tas_string(delta)


def scramble_byte(value, bit_order):
    assert(len(bit_order) == BITS_PER_BYTE)
    bits = bin(value + BYTE_SIZE)[-BITS_PER_BYTE:]
    return int(''.join(bits[i] for i in bit_order), base=2)


def rng_calc(acc_value, frame_value):
    rng_value = scramble_byte(acc_value, get_mapping(BTN_ORDER_ACC, BTN_ORDER_RNG))
    rng_value += scramble_byte(frame_value, get_mapping(BIT_ORDER_BYTE, BIT_ORDER_FRAME))
    return rng_value % BYTE_SIZE


def rng_inv(rng_value, frame_value):
    frame_scrambled = scramble_byte(frame_value, get_mapping(BIT_ORDER_BYTE, BIT_ORDER_FRAME))
    if frame_scrambled > rng_value:
        acc_scrambled = BYTE_SIZE + rng_value - frame_scrambled
    else:
        acc_scrambled = rng_value - frame_scrambled

    return scramble_byte(acc_scrambled, get_mapping(BTN_ORDER_RNG, BTN_ORDER_ACC))


def rng_manip(acc_value, frame_value, rng_desired):
    return tas_manip(acc_value, rng_inv(rng_desired, frame_value))


def main():
    from argparse import ArgumentParser
    desc = "RNG related functions for Mike Tyson's Punch-Out"
    argument_parser = ArgumentParser(description=desc)
    subparsers = argument_parser.add_subparsers(dest='command')

    def byte(x):
        value = int(x, base=0)
        if 0 <= value < BYTE_SIZE:
            return value
        else:
            raise ValueError('value out of range for unsigned byte')

    parser = subparsers.add_parser('calc', help='calculate RNG value from acc and frame')
    parser.add_argument("acc", type=byte, help="value of input accumulator")
    parser.add_argument("frame", type=byte, help="value of frame counter")

    parser = subparsers.add_parser('inv', help='calculate acc value from RNG and frame')
    parser.add_argument("rng", type=byte, help="value of RNG")
    parser.add_argument("frame", type=byte, help="value of frame counter")

    parser = subparsers.add_parser('tas', help='manipulate input accumulator to desired value')
    parser.add_argument("current", type=byte, help="current value of input accumulator")
    parser.add_argument("desired", type=byte, help="desired value of input accumulator")

    parser = subparsers.add_parser('manip', help='manipulate input to achieve desired RNG')
    parser.add_argument("acc", type=byte, help="value of input accumulator")
    parser.add_argument("frame", type=byte, help="value of frame counter")
    parser.add_argument("rng", type=byte, help="desired value of RNG")

    args = argument_parser.parse_args()
    if args.command == "tas":
        assert(tas_manip(105, 207) == '--STUD--')
        tas_string = tas_manip(args.current, args.desired)
        print('tas manip 0x%02X to 0x%02X: %s' % (args.current, args.desired, tas_string))
    elif args.command == "manip":
        assert(rng_manip(105, 156, rng_calc(207, 156)) == '--STUD--')
        tas_string = rng_manip(args.acc, args.frame, args.rng)
        print('rng manip($19=0x%02X, $1E=0x%02X, $18=0x%02X) : %s' % (args.acc, args.frame, args.rng, tas_string))
    elif args.command == "calc":
        assert(rng_calc(83, 156) == 145)
        rng_value = rng_calc(args.acc, args.frame)
        print('rng calc($19=0x%02X, $1E=0x%02X): $18=0x%02X' % (args.acc, args.frame, rng_value))
    elif args.command == "inv":
        assert(rng_inv(rng_calc(83, 156), 156) == 83)
        acc_value = rng_inv(args.rng, args.frame)
        print('rng inv($18=0x%02X, $1E=0x%02X): $19=0x%02X' % (args.rng, args.frame, acc_value))
    else:
        argument_parser.print_help()


if __name__ == "__main__":
    main()
