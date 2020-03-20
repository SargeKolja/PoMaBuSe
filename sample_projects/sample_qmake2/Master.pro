TEMPLATE = subdirs

SUBDIRS = \
	MainApp	\
	Sub2	\
	Sub3

# CONFIG += ordered  # no, then we would need set MainApp as the last Element. Insted we use:
MainApp.depend = Sub2 Sub3
