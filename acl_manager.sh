#!/bin/bash

# ACL Management Script for PhantomPlay MTA Server
# This script helps manage ACL configuration and reload it safely

echo "PhantomPlay ACL Management Script"
echo "================================="

# Function to backup current ACL
backup_acl() {
    if [ -f "acl.xml" ]; then
        cp acl.xml "acl.xml.backup.$(date +%Y%m%d_%H%M%S)"
        echo "✅ ACL backed up successfully"
    else
        echo "❌ No acl.xml file found to backup"
        return 1
    fi
}

# Function to validate ACL XML syntax
validate_acl() {
    if command -v xmllint >/dev/null 2>&1; then
        if xmllint --noout acl.xml 2>/dev/null; then
            echo "✅ ACL XML syntax is valid"
            return 0
        else
            echo "❌ ACL XML syntax is invalid"
            xmllint --noout acl.xml
            return 1
        fi
    else
        echo "⚠️  xmllint not available, skipping syntax validation"
        return 0
    fi
}

# Function to show ACL groups
show_groups() {
    echo ""
    echo "Current ACL Groups:"
    echo "=================="
    if [ -f "acl.xml" ]; then
        grep -o '<group name="[^"]*"' acl.xml | sed 's/<group name="//; s/"//' | sort
    else
        echo "❌ No acl.xml file found"
    fi
}

# Function to show ACL lists
show_acls() {
    echo ""
    echo "Current ACL Lists:"
    echo "=================="
    if [ -f "acl.xml" ]; then
        grep -o '<acl name="[^"]*"' acl.xml | sed 's/<acl name="//; s/"//' | sort
    else
        echo "❌ No acl.xml file found"
    fi
}

# Main menu
case "${1:-menu}" in
    "backup")
        backup_acl
        ;;
    "validate")
        validate_acl
        ;;
    "groups")
        show_groups
        ;;
    "acls")
        show_acls
        ;;
    "reload")
        echo "Validating ACL before reload..."
        if validate_acl; then
            echo "Use the following command in MTA server console or admin panel:"
            echo "  reloadacl"
            echo ""
            echo "Or via admin command:"
            echo "  /reloadacl"
        else
            echo "❌ ACL validation failed. Please fix errors before reloading."
            exit 1
        fi
        ;;
    "assign")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 assign <username> <group>"
            echo "Example: $0 assign PhantomDave PhantomPlayAdmin"
            echo ""
            echo "Available groups:"
            show_groups
        else
            echo "To assign user '$2' to group '$3', use this command in MTA console:"
            echo "  aclGroupAddObject $3 user.$2"
            echo ""
            echo "Or via admin panel in the ACL management section."
        fi
        ;;
    "menu"|*)
        echo ""
        echo "Available commands:"
        echo "  $0 backup   - Backup current ACL"
        echo "  $0 validate - Validate ACL XML syntax"
        echo "  $0 groups   - List all ACL groups"
        echo "  $0 acls     - List all ACL lists"
        echo "  $0 reload   - Instructions to reload ACL"
        echo "  $0 assign <user> <group> - Instructions to assign user to group"
        echo ""
        show_groups
        echo ""
        show_acls
        ;;
esac
