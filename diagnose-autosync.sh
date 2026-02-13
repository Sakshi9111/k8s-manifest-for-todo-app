#!/bin/bash

# ArgoCD Auto-Sync Diagnostic Script

APP_NAME="${1:-todo-app}"

echo "================================================"
echo "ArgoCD Auto-Sync Diagnostics for: $APP_NAME"
echo "================================================"
echo ""

echo "1. Checking if application exists..."
if ! kubectl get application $APP_NAME -n argocd &>/dev/null; then
    echo "❌ Application '$APP_NAME' not found in argocd namespace"
    exit 1
fi
echo "✅ Application found"
echo ""

echo "2. Checking sync policy configuration..."
echo "================================================"
kubectl get application $APP_NAME -n argocd -o jsonpath='{.spec.syncPolicy}' | jq '.'
echo ""

AUTO_SYNC=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.spec.syncPolicy.automated}')
if [ -z "$AUTO_SYNC" ] || [ "$AUTO_SYNC" == "null" ]; then
    echo "❌ Auto-sync is NOT enabled!"
    echo ""
    echo "To enable auto-sync, run:"
    echo "kubectl patch application $APP_NAME -n argocd --type merge -p '{\"spec\":{\"syncPolicy\":{\"automated\":{\"prune\":true,\"selfHeal\":true}}}}'"
    echo ""
else
    echo "✅ Auto-sync is enabled"
    echo ""
fi

echo "3. Checking repository configuration..."
echo "================================================"
REPO_URL=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.spec.source.repoURL}')
TARGET_REVISION=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.spec.source.targetRevision}')
PATH=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.spec.source.path}')

echo "Repository URL: $REPO_URL"
echo "Branch/Revision: $TARGET_REVISION"
echo "Path: $PATH"
echo ""

echo "4. Checking repository connection status..."
echo "================================================"
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository -o custom-columns=NAME:.metadata.name,URL:.data.url | while read name url; do
    if [ "$name" != "NAME" ]; then
        decoded_url=$(echo "$url" | base64 -d 2>/dev/null)
        echo "Repository: $decoded_url"
    fi
done
echo ""

echo "5. Checking current sync status..."
echo "================================================"
SYNC_STATUS=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.sync.status}')
HEALTH_STATUS=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.health.status}')
OPERATION_STATE=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.operationState.phase}')

echo "Sync Status: $SYNC_STATUS"
echo "Health Status: $HEALTH_STATUS"
echo "Operation State: $OPERATION_STATE"
echo ""

if [ "$SYNC_STATUS" == "OutOfSync" ]; then
    echo "⚠️  Application is OUT OF SYNC"
    echo "   ArgoCD has detected changes but hasn't synced yet."
    echo "   Default polling interval is 3 minutes."
    echo ""
elif [ "$SYNC_STATUS" == "Synced" ]; then
    echo "✅ Application is SYNCED"
    echo ""
else
    echo "⚠️  Unknown sync status: $SYNC_STATUS"
    echo ""
fi

echo "6. Checking last sync time..."
echo "================================================"
LAST_SYNC=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.operationState.finishedAt}')
if [ -n "$LAST_SYNC" ] && [ "$LAST_SYNC" != "null" ]; then
    echo "Last sync: $LAST_SYNC"
else
    echo "No sync has been performed yet"
fi
echo ""

echo "7. Checking for sync errors..."
echo "================================================"
CONDITIONS=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.conditions}')
if [ -n "$CONDITIONS" ] && [ "$CONDITIONS" != "null" ]; then
    echo "Conditions found:"
    echo "$CONDITIONS" | jq '.'
else
    echo "✅ No error conditions"
fi
echo ""

echo "8. Checking reconciliation timeout setting..."
echo "================================================"
TIMEOUT=$(kubectl get configmap argocd-cm -n argocd -o jsonpath='{.data.timeout\.reconciliation}' 2>/dev/null)
if [ -z "$TIMEOUT" ]; then
    echo "Reconciliation timeout: 180s (default - checks every 3 minutes)"
    echo ""
    echo "To reduce polling interval to 60 seconds:"
    echo "kubectl patch configmap argocd-cm -n argocd --type merge -p '{\"data\":{\"timeout.reconciliation\":\"60s\"}}'"
    echo "kubectl rollout restart statefulset argocd-application-controller -n argocd"
else
    echo "Reconciliation timeout: $TIMEOUT"
fi
echo ""

echo "9. Recent application controller logs..."
echo "================================================"
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=20 | grep -i "$APP_NAME" || echo "No recent logs for this application"
echo ""

echo "================================================"
echo "Recommendations"
echo "================================================"
echo ""

if [ -z "$AUTO_SYNC" ] || [ "$AUTO_SYNC" == "null" ]; then
    echo "1. ❌ CRITICAL: Enable auto-sync first!"
    echo "   kubectl patch application $APP_NAME -n argocd --type merge -p '{\"spec\":{\"syncPolicy\":{\"automated\":{\"prune\":true,\"selfHeal\":true}}}}'"
    echo ""
fi

if [ "$SYNC_STATUS" == "OutOfSync" ]; then
    echo "2. ⚠️  Application is out of sync. Options:"
    echo "   a) Wait up to 3 minutes for auto-sync to trigger"
    echo "   b) Force immediate sync:"
    echo "      kubectl patch application $APP_NAME -n argocd -p '{\"metadata\":{\"annotations\":{\"argocd.argoproj.io/refresh\":\"hard\"}}}' --type merge"
    echo ""
fi

echo "3. To test if sync is working:"
echo "   a) Make a change in your Git repository"
echo "   b) Wait 3 minutes (default polling interval)"
echo "   c) Watch status: watch kubectl get application $APP_NAME -n argocd"
echo ""

echo "4. For instant updates, configure webhooks:"
echo "   See: ARGOCD_AUTOSYNC_TROUBLESHOOTING.md"
echo ""

echo "5. To manually sync now:"
echo "   kubectl patch application $APP_NAME -n argocd --type merge -p '{\"operation\":{\"initiatedBy\":{\"username\":\"admin\"},\"sync\":{\"revision\":\"HEAD\"}}}'"
echo ""

echo "================================================"
echo "Diagnostic Complete"
echo "================================================"
