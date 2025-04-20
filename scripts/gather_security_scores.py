import os
import json
import csv
import sys
from collections import defaultdict

def parse_tfsec_output(data):
    """Parse tfsec output and count issues by severity, ignoring duplicates."""
    severity_counts = defaultdict(int)
    for issue in data.get("failed_checks", []):
        if issue.get("duplicate", False):  # Filter out duplicates
            continue
        severity = issue.get("severity", "UNKNOWN").upper()
        severity_counts[severity] += 1
    return severity_counts

def parse_checkov_output(data):
    """Parse checkov output and count issues by severity."""
    severity_counts = defaultdict(int)
    for issue in data.get("failed_checks", []):
        severity = issue.get("severity", "UNKNOWN").upper()
        severity_counts[severity] += 1
    return severity_counts

def gather_security_scores(base_dir):
    results = defaultdict(lambda: defaultdict(lambda: defaultdict(lambda: defaultdict(int))))
    # {tool: {LLM Model: {Scenario: {severity: count}}}}

    # Define directories to process
    tools = ["checkov", "tfsec"]
    for tool in tools:
        tool_dir = os.path.join(base_dir, f"results/{tool}")

        if tool == "tfsec":
            # Recursively find all parsed_output.json files in the tfsec directory
            for root, _, files in os.walk(tool_dir):
                if "parsed_output.json" in files:
                    parsed_output_path = os.path.join(root, "parsed_output.json")
                    parts = root.split(os.sep)
                    if len(parts) >= 3:
                        llm_model = parts[-2]
                        scenario = parts[-1]
                    else:
                        continue

                    with open(parsed_output_path, "r") as f:
                        try:
                            data = json.load(f)
                            tfsec_results = parse_tfsec_output(data)
                            for severity, count in tfsec_results.items():
                                results[tool][llm_model][scenario][severity] += count
                        except json.JSONDecodeError as e:
                            print(f"Error decoding JSON in {parsed_output_path}: {e}")
        elif tool == "checkov":
            # Recursively find all parsed_output.json files in the checkov directory
            for root, _, files in os.walk(tool_dir):
                if "parsed_output.json" in files:
                    parsed_output_path = os.path.join(root, "parsed_output.json")
                    parts = root.split(os.sep)
                    if len(parts) >= 3:
                        llm_model = parts[-2]
                        scenario = parts[-1]
                    else:
                        continue

                    with open(parsed_output_path, "r") as f:
                        try:
                            data = json.load(f)
                            checkov_results = parse_checkov_output(data)
                            for severity, count in checkov_results.items():
                                results[tool][llm_model][scenario][severity] += count
                        except json.JSONDecodeError as e:
                            print(f"Error decoding JSON in {parsed_output_path}: {e}")

    return results

def print_security_scores(scores):
    for tool, models in scores.items():
        print(f"Security scores for {tool}:")
        for model, scenarios in models.items():
            print(f"  LLM Model: {model}")
            for scenario, severities in scenarios.items():
                print(f"    Scenario: {scenario}")
                for severity, count in severities.items():
                    print(f"      {severity}: {count}")
        print()

def export_scores_to_csv(scores):
    """Export the security scores to CSV format and output to stdout."""
    writer = csv.writer(sys.stdout)
    # Write the header
    writer.writerow(["Tool", "LLM Model", "Scenario", "Severity", "Count"])
    
    # Write the data
    for tool, models in scores.items():
        for model, scenarios in models.items():
            for scenario, severities in scenarios.items():
                for severity, count in severities.items():
                    writer.writerow([tool, model, scenario, severity, count])

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.dirname(__file__))  # Adjust base directory as needed
    scores = gather_security_scores(base_dir)
    print_security_scores(scores)
    
    # Export scores to CSV
    print("\nCSV Output:")
    export_scores_to_csv(scores)
