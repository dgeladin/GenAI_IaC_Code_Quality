import os
import json

def load_severity_mapping(mapping_file):
    severity_mapping = {}
    try:
        with open(mapping_file, 'r') as file:
            for line in file:
                check_id, severity = line.strip().split(':')
                severity_mapping[check_id] = severity
    except FileNotFoundError:
        print(f"Severity mapping file not found: {mapping_file}")
    return severity_mapping

def process_json_files(directory, mapping_file):
    severity_mapping = load_severity_mapping(mapping_file)

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file == 'checkov_output.json':
                json_file_path = os.path.join(root, file)
                output_file_path = os.path.join(root, 'parsed_output.json')

                with open(json_file_path, 'r') as file:
                    data = json.load(file)

                if isinstance(data, dict):
                    process_result2(data, output_file_path, severity_mapping)
                elif isinstance(data, list):
                    for item in data:
                        if isinstance(item, dict):
                            process_result2(item, output_file_path, severity_mapping)
                        else:
                            print(f"Unexpected data type in list: {type(item)}")
                else:
                    print(f"Unexpected data type: {type(data)}")

                print(f"Processed: {json_file_path}")

def process_result2(result, output_file, severity_mapping):
    check_type = result.get('check_type', 'Unknown')
    failed_checks = result.get('results', {}).get('failed_checks', [])
    summary = result.get('summary', {})

    severity_counts = {
        "CRITICAL": 0,
        "HIGH": 0,
        "MEDIUM": 0,
        "LOW": 0,
        "UNKNOWN": 0
    }

    output_data = {
        "check_type": check_type,
        "failed_checks": [],
        "summary": {
            "passed": summary.get('passed', 'N/A'),
            "failed": summary.get('failed', 'N/A'),
            "skipped": summary.get('skipped', 'N/A'),
            "parsing_errors": summary.get('parsing_errors', 'N/A'),
            "resource_count": summary.get('resource_count', 'N/A'),
            "checkov_version": summary.get('checkov_version', 'N/A'),
            "severity_counts": severity_counts
        }
    }

    for check in failed_checks:
        check_id = check.get('check_id', 'N/A')
        severity = severity_mapping.get(check_id, 'Unknown')
        severity_counts[severity] = severity_counts.get(severity, 0) + 1

        failed_check = {
            "check_id": check_id,
            "severity": severity,
            "check_name": check.get('check_name', 'N/A'),
            "check_result": check.get('check_result', {}).get('result', 'N/A'),
            "file_path": check.get('file_path', 'N/A'),
            "file_line_range": check.get('file_line_range', 'N/A'),
            "resource": check.get('resource', 'N/A'),
            "guideline": check.get('guideline', 'N/A')
        }
        output_data["failed_checks"].append(failed_check)

    with open(output_file, "w") as f:
        json.dump(output_data, f, indent=2)


# Example usage
process_json_files('../results/checkov', '../data/misc/CHECKOV_ID_MAPPING.txt')

