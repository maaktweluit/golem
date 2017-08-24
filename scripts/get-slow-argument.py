# Check if this build can skip slow tests
# Skipping happens when build is a PR with < 2 approvals
# - input: pull_id from CI ( argv ) 
# - output: argument to use for this test ( stdout )

import sys
import json
import urllib.request;

pull_request_id = sys.argv[1]
run_slow = True

# When build is not a PR the input is: "" or "false"
if pull_request_id not in ["", "false"]:
    base_url = "https://api.github.com/repos/golemfactory/golem/pulls/{}/reviews"
    url = base_url.format(pull_request_id)
    
    try:
        # Github API requires user agent.
        req = urllib.request.Request(url,headers={'User-Agent':'build-bot'})
        with urllib.request.urlopen(req,timeout=10) as f:
            data = f.read().decode('utf-8')

        json_data = json.loads(data)
        result = [a for a in json_data if a["state"] is not "APPROVED"]
        approvals = len(result)
        run_slow = approvals >= 2
    except:
        sys.stderr.write("Error calling github, run all tests. {}".format(url))

if run_slow:
    # Space in front is important for more arguments later.
    print(" --runslow")
else:
    print("")
