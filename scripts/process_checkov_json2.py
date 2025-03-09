import os
import json

def process_json_files(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file == 'checkov_output.json':
                json_file_path = os.path.join(root, file)
                output_file_path = os.path.join(root, 'parsed_output.txt')

                with open(json_file_path, 'r') as file:
                    data = json.load(file)

                with open(output_file_path, 'w') as output_file:
                    if isinstance(data, dict):
                        process_result(data, output_file)
                    elif isinstance(data, list):
                        for item in data:
                            if isinstance(item, dict):
                                process_result(item, output_file)
                            else:
                                output_file.write(f"Unexpected data type in list: {type(item)}\n")
                    else:
                        output_file.write(f"Unexpected data type: {type(data)}\n")

                print(f"Processed: {json_file_path}")

def process_result(result, output_file):
    check_type = result.get('check_type', 'Unknown')
    failed_checks = result.get('results', {}).get('failed_checks', [])
    summary = result.get('summary', {})

    output_file.write(f"Check Type: {check_type}\n")
    output_file.write("Failed Checks:\n")
    for check in failed_checks:
        output_file.write(f"- Check ID: {check.get('check_id', 'N/A')}\n")
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
process_json_files('../results/checkov')
