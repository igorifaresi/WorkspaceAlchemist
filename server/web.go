package main

import (
	"encoding/json"
	"log"
	"strconv"

	"github.com/gofiber/fiber/v3"
)

func InitWebServer(port int) {
	log.Println("initing web server at "+strconv.Itoa(port))

    app := fiber.New()

    app.Post("/", func(c fiber.Ctx) error {
        return c.SendString("Test")
    })

    app.Post("/:name/query", func(c fiber.Ctx) error {
        name := c.Params("name")

        var source *Source = nil 
        for _, it := range Sources {
            if name == it.Name {
                source = &it 
            }
        }

        if source == nil {
            msg := "unable to find source: "+name
            log.Println(msg)
            return c.Status(400).SendString(msg)
        }

        bodyRaw := c.BodyRaw()
        var payload map[string]string
        err := json.Unmarshal(bodyRaw, &payload)
        if err != nil { 
            err2 := AppendToError(err, "error reading the json")
            log.Println(err2)
            return c.Status(400).SendString(err2.Error())
        }

        output, err := source.Connector.Query(payload)
        if err != nil {
            err2 := AppendToError(err, "error in quering the \""+source.Name+"\"")
            log.Println(err2)
            return c.Status(500).SendString(err.Error())
        }
        
        return c.SendString(output)
    })

    app.Listen(":"+strconv.Itoa(port))
}