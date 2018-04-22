##
#  Copyright : Copyright (c) MOSEK ApS, Denmark. All rights reserved.
#
#  File :      mioinitsol.py
#
#  Purpose :   Demonstrates how to solve a small mixed
#              integer linear optimization problem using the MOSEK Python API.
##
import sys
import mosek

# Since the actual value of Infinity is ignores, we define it solely
# for symbolic purposes:
inf = 0.0

# Define a stream printer to grab output from MOSEK
def streamprinter(text):
    sys.stdout.write(text)
    sys.stdout.flush()


def main():
    # Make a MOSEK environment
    with mosek.Env() as env:
        # Attach a printer to the environment
        env.set_Stream(mosek.streamtype.log, streamprinter)

        # Create a task
        with env.Task(0, 0) as task:
            # Attach a printer to the task
            task.set_Stream(mosek.streamtype.log, streamprinter)

            bkc = [mosek.boundkey.up]
            blc = [-inf, ]
            buc = [2.5]

            bkx = [mosek.boundkey.lo,
                   mosek.boundkey.lo,
                   mosek.boundkey.lo,
                   mosek.boundkey.lo]

            blx = [0.0, 0.0, 0.0, 0.0]
            bux = [inf, inf, inf, inf]

            c = [7.0, 10.0, 1.0, 5.0]

            asub = [0, 0, 0, 0]
            acof = [1.0, 1.0, 1.0, 1.0]

            ptrb = [0, 1, 2, 3]
            ptre = [1, 2, 3, 4]

            numvar = len(bkx)
            numcon = len(bkc)

            # Input linear data
            task.inputdata(numcon, numvar,
                           c, 0.0,
                           ptrb, ptre, asub, acof,
                           bkc, blc, buc,
                           bkx, blx, bux)

            # Input objective sense
            task.putobjsense(mosek.objsense.maximize)

            # Define variables to be integers

            task.putvartypelist([0, 1, 2],
                                [mosek.variabletype.type_int,
                                 mosek.variabletype.type_int,
                                 mosek.variabletype.type_int])

            # Construct an initial feasible solution from the
            #     values of the integer valuse specified
            task.putintparam(mosek.iparam.mio_construct_sol,
                             mosek.onoffkey.on)

            # Assign values 0,2,0 to integer variables. Important to
            # assign a value to all integer constrained variables.
            task.putxxslice(mosek.soltype.itg, 0, 3, [0.0, 2.0, 0.0])

            # Optimize
            task.optimize()

            # Did mosek construct a feasible initial solution ?
            if task.getintinf(mosek.iinfitem.mio_construct_solution) > 0:
                print("Objective value of constructed integer solution: %-24.12e" %
                      task.getdouinf(mosek.dinfitem.mio_construct_solution_obj))
            else:
                print("Intial integer solution construction failed.")

            if task.solutiondef(mosek.soltype.itg):

                # Output a solution
                xx = [0.] * numvar
                task.getxx(mosek.soltype.itg, xx)
                print("Integer optimal solution")
                for j in range(0, numvar):
                    print("\tx[%d] = %e" % (j, xx[j]))
            else:
                print("No integer solution is available.")

# call the main function
try:
    main()
except mosek.MosekException as e:
    print("ERROR: %s" % str(e.errno))
    if e.msg is not None:
        print("\t%s" % e.msg)
    sys.exit(1)
except:
    import traceback
    traceback.print_exc()
    sys.exit(1)