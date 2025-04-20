import os
import json
import csv
import sys
from collections import defaultdict

def parse_tfsec_output(data):
    """Parse tfsec output and count issues by type and severity, ignoring duplicates."""
    issue_counts = defaultdict(lambda: defaultdict(int))  # {issue_type: {severity: count}}
    for issue in data.get("failed_checks", []):
        if issue.get("duplicate", False):  # Filter out duplicates
            continue
        issue_type = issue.get("rule_id", "UNKNOWN")
        severity = issue.get("severity", "UNKNOWN").upper()
        issue_counts[issue_type][severity] += 1
    return issue_counts

def parse_checkov_output(data):
    """Parse checkov output and count issues by type and severity."""
    issue_counts = defaultdict(lambda: defaultdict(int))  # {issue_type: {severity: count}}
    for issue in data.get("failed_checks", []):
        issue_type = issue.get("check_id", "UNKNOWN")
        severity = issue.get("severity", "UNKNOWN").upper()
        issue_counts[issue_type][severity] += 1
    return issue_counts

def gather_security_issues(base_dir):
    results = defaultdict(lambda: defaultdict(lambda: defaultdict(lambda: defaultdict(int))))
    # {tool: {LLM Model: {issue_type: {severity: count}}}}

    # Define directories to process
    tools = ["checkov", "tfsec"]
    for tool in tools:
        tool_dir = os.path.join(base_dir, f"results/{tool}")

        if tool == "tfsec":
            # Recursively find all parsed_output.json files in the tfsec directory
            for root, _, files in os.walk(tool_dir):
                if "parsed_output.json" in files:
                    print(f"Processing: {root}")  # Debugging: Print the directory being processed
                    parsed_output_path = os.path.join(root, "parsed_output.json")
                    parts = root.split(os.sep)
                    if len(parts) >= 2:
                        llm_model = parts[-2]
                    else:
                        continue

                    with open(parsed_output_path, "r") as f:
                        try:
                            data = json.load(f)
                            tfsec_results = parse_tfsec_output(data)
                            for issue_type, severities in tfsec_results.items():
                                for severity, count in severities.items():
                                    results[tool][llm_model][issue_type][severity] += count
                        except json.JSONDecodeError as e:
                            print(f"Error decoding JSON in {parsed_output_path}: {e}")
        elif tool == "checkov":
            # Recursively find all parsed_output.json files in the checkov directory
            for root, _, files in os.walk(tool_dir):
                if "parsed_output.json" in files:
                    print(f"Processing: {root}")  # Debugging: Print the directory being processed
                    parsed_output_path = os.path.join(root, "parsed_output.json")
                    parts = root.split(os.sep)
                    if len(parts) >= 2:
                        llm_model = parts[-2]
                    else:
                        continue

                    with open(parsed_output_path, "r") as f:
                        try:
                            data = json.load(f)
                            checkov_results = parse_checkov_output(data)
                            for issue_type, severities in checkov_results.items():
                                for severity, count in severities.items():
                                    results[tool][llm_model][issue_type][severity] += count
                        except json.JSONDecodeError as e:
                            print(f"Error decoding JSON in {parsed_output_path}: {e}")

    return results

def print_security_issues(issues):
    for tool, models in issues.items():
        print(f"Security issues for {tool}:")
        for model, issue_types in models.items():
            print(f"  LLM Model: {model}")
            for issue_type, severities in issue_types.items():
                print(f"    {issue_type}:")
                for severity, count in severities.items():
                    print(f"      {severity}: {count}")
        print()

def export_issues_to_csv(issues):
    """Export the security issues to CSV format and output to stdout."""
    writer = csv.writer(sys.stdout)
    # Write the header
    writer.writerow(["Tool", "LLM Model", "Issue Type", "Severity", "Count"])
    
    # Write the data
    for tool, models in issues.items():
        for model, issue_types in models.items():
            for issue_type, severities in issue_types.items():
                for severity, count in severities.items():
                    writer.writerow([tool, model, issue_type, severity, count])

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # Adjust base directory as one level up
    print(f"Base directory: {base_dir}")  # Debugging: Print the base directory
    issues = gather_security_issues(base_dir)
    print_security_issues(issues)
    
    # Export issues to CSV
    print("\nCSV Output:")
    export_issues_to_csv(issues)
