package test

import (
	"fmt"
	"testing"
	awsSDK "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)


func TestMaintenanceWindowDynamoDbTable(t *testing.T) {
	t.Parallel()
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	expectedTableName := fmt.Sprint("MaintenanceWindow")
	expectedKeySchema := []*dynamodb.KeySchemaElement{
		{
			AttributeName: awsSDK.String("Name"), KeyType: awsSDK.String("HASH"),
		},
		{
			AttributeName: awsSDK.String("account-region"), KeyType: awsSDK.String("RANGE"),
		},
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	table := aws.GetDynamoDBTable(t, awsRegion, expectedTableName)
	assert.Equal(t, "ACTIVE", awsSDK.StringValue(table.TableStatus))
	assert.ElementsMatch(t, expectedKeySchema, table.KeySchema)
}