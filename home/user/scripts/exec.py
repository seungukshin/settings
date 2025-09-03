#!/usr/bin/env python3

import subprocess as sp
import sys

################################################################################
# execute shell command
################################################################################
def exec_cmd(cmd: [str], shell: bool, wait: bool,
             print_cmd: bool = True, print_out: bool = False,
             stdin = sp.PIPE, stdout = sp.PIPE,
             stderr = sp.PIPE) -> tuple[int, str, str] | sp.Popen:
    '''
    This function executes ``cmd`` and returns a result.

    :param cmd: List of command separated by space if ``shell`` is ``False``,
        otherwise list containing one string including entire command line.
    :param shell: Whether executing command through the shell or not.
        ``shell`` should be ``True`` to use shell pipes, filename whildcards,
        or environment variables.
    :param wait: Whether waiting completion of execution or not.
        If ``wait`` is ``True``, this function waits for completion and
        returns the return value from the command.
        If ``wait`` is ``False``, this function does not wait for completion
        and returns the ``Popen`` object.
    :param print_cmd: Whether print the command before execution.
    :param print_out: Whether print the output of execution of the command.
        This is only valid when ``wait`` is ``True``.
    :param stdin: Standard input. It can be None, PIPE, DEVNULL or file object.
    :param stdout: Standard output. It can be None, PIPE, DEVNULL or file object.
    :param stderr: Standard error. It can be None, PIPE, DEVNULL or file object.
    :returns: ``Popen`` object if ``wait`` is ``False``,
        otherwise return value from the command.
    '''
    if print_cmd:
        print(f'$ {" ".join(cmd)}')
    p = sp.Popen(cmd, shell=shell, text=True, universal_newlines=True,
                 stdin=stdin, stdout=stdout, stderr=stderr)

    if wait:
        output, errors = p.communicate()
        if p.returncode != 0:
            print(f'fail to execute command: {" ".join(cmd)}')
            print('return:', p.returncode)
            print('output:', output, end='')
            print('errors:', errors, end='')
        elif print_out:
            stripped_output = output.strip()
            if stripped_output:
                print(stripped_output)
            stripped_errors = errors.strip()
            if stripped_errors:
                print(stripped_errors)
        return p.returncode, output, errors
    else:
        return p

################################################################################
# ssh helper
################################################################################
def ssh_cmd(server: str, cmd: str) -> int:
    '''
    The function executes ``cmd`` in ``server`` and returns its pid.
    '''
    _, out, _ = exec.exec_cmd([f'ssh {server} "{cmd} > /dev/null 2>&1 & echo \\$!; disown"'],
                              True, True, True, False)
    return int(out.strip())

def ssh_kill_pid(server: str, pid: int) -> None:
    exec.exec_cmd([f'ssh {server} "kill -2 {pid}"'], True, True, True, True)
    return

def ssh_wait_pid(server: str, pid: int) -> None:
    exec.exec_cmd([f'ssh {server} "tail --pid={pid} -f /dev/null"'],
                  True, True, True, True)
    return

def ssh_move_file(server: str, src: str, dst: str) -> None:
    exec.exec_cmd([f'scp {server}:{src} {dst}'], True, True, True, True)
    exec.exec_cmd([f'ssh {server} "rm -rf {src}"'], True, True, True, True)
    return

################################################################################
# main
################################################################################
def main(cmd: [str]) -> int:
    exec_cmd(cmd, False, True, True, True)
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
