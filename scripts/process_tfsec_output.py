import json
import sys

def parse_results(json_data):
    results = []
    for result in json_data["results"]:
        parsed_result = {
            "rule_id": result["rule_id"],
            "long_id": result["long_id"],
            "rule_description": result["rule_description"],
            "rule_provider": result["rule_provider"],
            "rule_service": result["rule_service"],
            "impact": result["impact"],
            "resolution": result["resolution"],
            "links": result["links"],
            "description": result["description"],
            "severity": result["severity"],
            "warning": result["warning"],
            "status": result["status"],
            "resource": result["resource"],
            "location": {
                "filename": result["location"]["filename"],
                "start_line": result["location"]["start_line"],
                "end_line": result["location"]["end_line"]
            }
        }
        results.append(parsed_result)
    return results

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python parse_json.py <filename>")
        sys.exit(1)

    filename = sys.argv[1]

    with open(filename, "r") as file:
        json_data = json.load(file)

    results = parse_results(json_data)

    print(f"Failed Checks: " ) 

    for result in results:
        print(f"- Check ID: {result['rule_id']} (Severity: {result['severity']})")
        print(f"  Check Name: {result['rule_description']}")
        print(f"  Check Result: FAILED")
        print(f"  File Path: {result['location']['filename']}")
        print(f"  File Line Range: {result['location']['start_line']}-{result['location']['end_line']}")
        print(f"  Resource: {result['resource']}")
        print(f"  Guideline: {', '.join(result['links'])}")
        print(f" ")

