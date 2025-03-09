import json

def process_json_file(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)

    # Extract the relevant information
    check_type = data['check_type']
    failed_checks = data['results']['failed_checks']
    summary = data['summary']

    # Print the extracted information
    print(f"Check Type: {check_type}")
    print("Failed Checks:")
    for check in failed_checks:
        print(f"- Check ID: {check['check_id']}")
        print(f"  Check Name: {check['check_name']}")
        print(f"  Check Result: {check['check_result']['result']}")
        print(f"  File Path: {check['file_path']}")
        print(f"  File Line Range: {check['file_line_range']}")
        print(f"  Resource: {check['resource']}")
        print(f"  Guideline: {check['guideline']}")
        print()

    print("Summary:")
    print(f"  Passed: {summary['passed']}")
    print(f"  Failed: {summary['failed']}")
    print(f"  Skipped: {summary['skipped']}")
    print(f"  Parsing Errors: {summary['parsing_errors']}")
    print(f"  Resource Count: {summary['resource_count']}")
    print(f"  Checkov Version: {summary['checkov_version']}")

# Example usage
process_json_file('../results/checkov/Gemini/Scenario03/checkov_output.json')
