import json
import sys
import os

def process_json_files(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file == 'tfsec_output.json':
                json_file_path = os.path.join(root, file)
                output_file_path = os.path.join(root, 'parsed_output.json')

                with open(json_file_path, 'r') as file:
                    data = json.load(file)

                if isinstance(data, dict):
                    process_result(data, output_file_path)
                elif isinstance(data, list):
                    for item in data:
                        if isinstance(item, dict):
                            process_result(item, output_file_path)
                        else:
                            print(f"Unexpected data type in list: {type(item)}")
                else:
                    print(f"Unexpected data type: {type(data)}")

                print(f"Processed: {json_file_path}")

def process_result(data, output_file):
    results = []

    for result in data["results"]:
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
            },
            "duplicate": result.get("duplicate", False)
        }
        results.append(parsed_result)

    output = {
        "failed_checks": results
    }

    severity_counts = {
        "CRITICAL": 0,
        "HIGH": 0,
        "MEDIUM": 0,
        "LOW": 0,
        "UNKNOWN": 0,
        "INFO": 0
    }

    for result in results:
        severity = result["severity"]
        if severity in severity_counts:
            severity_counts[severity] += 1
        else:
            severity_counts["UNKNOWN"] = severity_counts.get("UNKNOWN", 0) + 1
            print(f"Unknown severity: {severity}")

    output["summary"] = severity_counts

    with open(output_file, "w") as f:
        json.dump(output, f, indent=2)

process_json_files('../results/tfsec')
