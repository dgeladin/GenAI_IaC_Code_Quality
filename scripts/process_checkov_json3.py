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
                output_file_path = os.path.join(root, 'parsed_output.txt')

                with open(json_file_path, 'r') as file:
                    data = json.load(file)

                with open(output_file_path, 'w') as output_file:
                    if isinstance(data, dict):
                        process_result(data, output_file, severity_mapping)
                    elif isinstance(data, list):
                        for item in data:
                            if isinstance(item, dict):
                                process_result(item, output_file, severity_mapping)
                            else:
                                output_file.write(f"Unexpected data type in list: {type(item)}\n")
                    else:
                        output_file.write(f"Unexpected data type: {type(data)}\n")

                print(f"Processed: {json_file_path}")

def process_result(result, output_file, severity_mapping):
    check_type = result.get('check_type', 'Unknown')
    failed_checks = result.get('results', {}).get('failed_checks', [])
    summary = result.get('summary', {})

    output_file.write(f"Check Type: {check_type}\n")
    output_file.write("Failed Checks:\n")
    for check in failed_checks:
        check_id = check.get('check_id', 'N/A')
        severity = severity_mapping.get(check_id, 'N/A')
        output_file.write(f"- Check ID: {check_id} (Severity: {severity})\n")
        output_file.write(f"  Check Name: {check.get('check_name', 'N/A')}\n")
        output_file.write(f"  Check Result: {check.get('check_result', {}).get('result', 'N/A')}\n")
        output_file.write(f"  File Path: {check.get('file_path', 'N/A')}\n")
        output_file.write(f"  File Line Range: {check.get('file_line_range', 'N/A')}\n")
        output_file.write(f"  Resource: {check.get('resource', 'N/A')}\n")
        output_file.write(f"  Guideline: {check.get('guideline', 'N/A')}\n")
        output_file.write("\n")

    output_file.write("Summary:\n")
    output_file.write(f"  Passed: {summary.get('passed', 'N/A')}\n")
    output_file.write(f"  Failed: {summary.get('failed', 'N/A')}\n")
    output_file.write(f"  Skipped: {summary.get('skipped', 'N/A')}\n")
    output_file.write(f"  Parsing Errors: {summary.get('parsing_errors', 'N/A')}\n")
    output_file.write(f"  Resource Count: {summary.get('resource_count', 'N/A')}\n")
    output_file.write(f"  Checkov Version: {summary.get('checkov_version', 'N/A')}\n")
    output_file.write("\n")

# Example usage
process_json_files('../results/checkov', '../data/misc/CHECKOV_ID_MAPPING.txt')
