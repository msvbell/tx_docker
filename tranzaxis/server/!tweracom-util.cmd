@rem ------------------ must edit ------------------------------
@rem Product subversion repository URL
@set SVN_URL="svn+ssh://svn.compassplus.ru/twrbs/trunk/test"

@rem Subversion authentication
@set SVN_AUTH=-authUser=svn -sshKeyFile=C:\Users\akaptsan.CP\Documents\svn.pem -sshKeyPasswordInteractive

@rem --------------- do not edit ------------------------------
@set APP_ARGS=
@set CLASS=com.tranzaxis.kernel.utils.tweracomUtil.TwEracomUtil

call #start_util.cmd
