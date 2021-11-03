COMMIT_MESSAGE ?= ""

RESULT_GIT = git --no-pager -C result

.PHONY: is-result-* commit update publish clean-result

commit:
	test -e result/.git
	$(RESULT_GIT) add .
	$(RESULT_GIT) commit --allow-empty-message --message $(COMMIT_MESSAGE)

update: $(RESULT_TARGETS)
	$(MAKE) commit

is-result-clean:
	@test -z "$$($(RESULT_GIT) status --short --untracked-files=no)"

is-result-synchronized: is-result-clean
	$(RESULT_GIT) pull --ff-only
	$(RESULT_GIT) push  # verify push-ability

publish: is-result-synchronized clean
	$(MAKE) update
	$(RESULT_GIT) push

clean-result:
	rm -fv result/*
