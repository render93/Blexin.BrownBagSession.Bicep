using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace BagBrownSession.FunctionApp;

public static class Database
{
    [FunctionName("Database")]
    public static async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req, ILogger log)
    {
        var str = Environment.GetEnvironmentVariable("DbConnectionString");
        await using var conn = new SqlConnection(str);
        conn.Open();
        var now = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        var command = "INSERT INTO Info (LastRun) VALUES (@now)";
        var cmd = new SqlCommand(command, conn);
        cmd.Parameters.AddWithValue("@now", now);
        await cmd.ExecuteNonQueryAsync();
        
        command = "SELECT * FROM Info";
        cmd = new SqlCommand(command, conn);
        var list = new List<string>();
        await using (var item = await cmd.ExecuteReaderAsync())
        {
            while (item.Read())
            {    
                list.Add(item["LastRun"].ToString());
            }
        } 
        return new OkObjectResult(list);
    }
}

